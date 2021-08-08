require 'find'
require 'net/ssh/gateway'
require 'ostruct'

module Crudboy
  class Bundle
    attr_accessor :path, :config, :result, :destination, :templates, :context

    def initialize_path(path)
      # TODO
      path
    end

    def parse_options(options)
      load_option_definitions
      return unless Object::const_defined?('TEMPLATE_OPTIONS')
      OpenStruct.new.tap do |result|

        TEMPLATE_OPTIONS.each do |definition|
          definition[:default].try do |default|
            result[definition[:name]] = default
          end
        end

        OptionParser.new do |opts|

          opts.banner = "Template Options:\n\n"

          TEMPLATE_OPTIONS.each do |definition|
            opts.on(*definition.values_at(:short, :long, :description)) do |value|
              result[definition[:name]] = value
            end
          end
          opts.on('', '--help', 'Prints this help') do
            puts opts
            exit
          end
        end.parse!(options)
      end
    end

    def load_option_definitions
      File.join(@path, "options.rb").try do |option_definitions_file|
        load(option_definitions_file)
      end
    end

    def initialize(path, options, destination, context)
      @path = initialize_path(path)
      @destination = destination
      @options = parse_options(options)
      @context = context
      @context.bundle_options = @options
      @templates = initialize_templates
    end

    def load_initializer!
      "#{@path}/init.rb".tap do |initializer_file|
        load(initializer_file) if File.exist?(initializer_file)
      end
    end

    def initialize_templates
      templates_path= File.join(@path, 'templates')
      Find.find(templates_path).map do |file_path|
        base_path = file_path.delete_prefix(templates_path)
        Template.new(file_path, base_path, @context)
      end
    end

    def render!
      load_initializer!
      templates.each do |template|
        template.render!(@destination)
      end
    end

  end
end
