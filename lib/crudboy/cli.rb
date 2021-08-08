require 'optparse'
require 'ostruct'

module Crudboy
  class Cli
    class << self
      def start
        parse_options!
        App.new(@options).run!
      end

      def parse_options!
        @options = OpenStruct.new(config_file: default_config_file,
                                  initializer: default_initializer,
                                  destination: Dir.pwd,
                                  ssh: {})


        OptionParser.new do |opts|
          opts.banner = <<~EOF
          Usage: crudboy [options] [ruby file]

            If neither [ruby file] nor -e option specified, and STDIN is not a tty, a Pry REPL will be launched,
            otherwise the specified ruby file or -e option value or ruby code read from STDIN will be run, and no REPL launched

          EOF

          opts.on('-cCONFIG_FILE', '--conf=CONFIG_FILE', 'Specify config file, default is $HOME/.crudboy.yml, or $HOME/.crudboy.d/init.yml.') do |config_file|
            @options.config_file = config_file
          end

          opts.on('-iINITIALIZER', '--initializer=INITIALIZER', 'Specify initializer ruby file, default is $HOME/.crudboy.rb, or $HOME/.crudboy.d/init.rb.') do |initializer|
            @options.initializer = initializer
          end

          opts.on('-eENVIRON', '--env=ENVIRON', 'Specify config environment.') do |env|
            @options.env = env
          end

          opts.on('-tTABLE_NAME', '--table=TABLE_NAME', 'Specify table name') do |table_name|
            @options.table_name = table_name
          end

          opts.on('-mMODEL_NAME', '--model=MODEL_NAME', 'Specify model name') do |model_name|
            @options.model_name = model_name
          end

          opts.on('-oOUTPUT', '--output=OUTPUT', 'Specify output path, default: $PWD') do |destination|
            @options.destination = destination
          end

          opts.on('-bTEMPLATE_BUNDLE', '--bundle=TEMPLATE_BUNDLE', 'Specify template bundle, may be a path point to a .crudboy file or a directory') do |template_bundle|
            @options.template_bundle = template_bundle
          end

          opts.on('', '--help', 'Prints this help') do
            puts opts
            exit
          end

        end.parse!

        @options.template_args = ARGV
      end

      def default_config_file
        conf = File.expand_path('~/.crudboy.yml')
        return conf if File.file?(conf)
        conf = File.expand_path('~/.crudboy.yaml')
        return conf if File.file?(conf)
        conf = File.expand_path('~/.crudboy.d/init.yml')
        return conf if File.file?(conf)
        conf = File.expand_path('~/.crudboy.d/init.yaml')
        return conf if File.file?(conf)
      end

      def default_initializer
        conf = File.expand_path('~/.crudboy.rb')
        return conf if File.file?(conf)
        conf = File.expand_path('~/.crudboy.d/init.rb')
        return conf if File.file?(conf)
      end
    end
  end
end
