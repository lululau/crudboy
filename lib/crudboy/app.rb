require 'net/ssh/gateway'

module Crudboy
  class App

    class << self
      attr_accessor :env, :prompt, :instance, :connect_options

      def config
        @@effective_config
      end
    end

    def initialize(options)
      require 'active_support/all'
      require 'active_record'
      require 'composite_primary_keys'
      require "crudboy/connection"
      require "crudboy/definition"
      @options = options
      App.env = @options.env
      App.connect_options = connect_options
      Connection.open(App.connect_options)
      @definition = Definition.new(effective_config)
      @context = TemplateContext.new(@definition)
      load_initializer!
      App.instance = self
    end

    def connect_options
      connect_conf = effective_config.slice(:adapter, :host, :username,
                             :password, :database, :encoding,
                             :pool, :port, :socket)
      if effective_config[:ssh].present?
        connect_conf.merge!(start_ssh_proxy!)
      end

      connect_conf
    end

    def load_initializer!
      return unless effective_config[:initializer]
      initializer_file = File.expand_path(effective_config[:initializer])
      unless File.exists?(initializer_file)
        STDERR.puts "Specified initializer file not found, #{effective_config[:initializer]}"
        exit(1)
      end
      load(initializer_file)
    end

    def start_ssh_proxy!
      ssh_config = effective_config[:ssh]
      local_ssh_proxy_port = Crudboy::SSHProxy.connect(
        ssh_config.slice(:host, :user, :port, :password).merge(
          forward_host: effective_config[:host],
          forward_port: effective_config[:port],
          local_port: ssh_config[:local_port]))

      {
        host: '127.0.0.1',
        port: local_ssh_proxy_port
      }
    end

    def config
      @config ||= YAML.load(IO.read(File.expand_path(@options.config_file))).with_indifferent_access
    end

    def selected_config
      if @options.env.present? && !config[@options.env].present?
        STDERR.puts "Specified ENV `#{@options.env}' not exists"
      end
      if env = @options.env
        config[env]
      else
        {}
      end
    end

    def effective_config
      @@effective_config ||= nil
      unless @@effective_config
        @@effective_config = selected_config.deep_merge(@options.to_h)
        if @@effective_config[:adapter].blank?
          @@effective_config[:adapter] = 'sqlite3'
        end
        @@effective_config[:database] = File.expand_path(@@effective_config[:database]) if @@effective_config[:adapter] == 'sqlite3'
      end
      @@effective_config
    end

    def run!
      Bundle.new(@options.template_bundle, @options.template_args, @options.destination, @context).render!
    end
  end
end
