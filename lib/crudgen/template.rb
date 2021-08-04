require 'erb'

module Crudgen
  class Template
    attr_accessor :path, :base_path, :type, :context

    def initialize(path, base_path, context)
      @path = path
      @base_path = base_path.blank? ? '.' : base_path
      @type = if File.directory?(@path)
                :directory
              elsif @path.end_with?('.erb')
                :erb
              else
                :plain
              end
      @context = context
    end

    def make_directory!(destination)
      @context.eval(@base_path).tap do |path|
        File.join(destination, path).tap do |full_path|
          FileUtils.mkdir_p(full_path)
        end
      end
    end

    def make_base_directory!(destination)
      @context.eval(@base_path).tap do |path|
        File.dirname(path).tap do |base_dir|
          File.join(destination, base_dir).tap do |full_path|
            FileUtils.mkdir_p(full_path)
          end
        end
      end
    end

    def render_file
      if erb?
        erb = ERB.new(IO.read(path))
        erb.filename = path
        erb.result(@context.binding)
      else
        IO.read(path)
      end
    end

    def render!(destination)
      if directory?
        make_directory!(destination)
      else
        make_base_directory!(destination)
        render_file.tap do |file_content|
          File.join(destination, @context.eval(@base_path.delete_suffix('.erb'))).tap do |path|
            IO.write(path, file_content)
          end
        end
      end
    end

    def directory?
      @type == :directory
    end

    def erb?
      @type == :erb
    end

    def plain?
      @type == :plain
    end
  end
end
