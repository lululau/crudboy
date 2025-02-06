module Crudboy
  class TemplateContext

    include Helper

    attr_accessor :model, :columns, :table_name, :table_comment, :model_name, :bundle_options

    def initialize(definition)
      @model = definition.model
      @model_name = definition.model_name
      @table_name = definition.table_name
      @table_comment = definition.table_comment
      @columns = @model.columns
    end

    def eval(string)
      instance_eval(format('%%Q{%s}', string), string, 0)
    end

    def binding
      Kernel::binding
    end

    def columns(**options)
      model.columns(**options)
    end

    def method_missing(method, *args, **options, &block)
      if args.empty? && options.empty? && block.nil? && bundle_options.table.keys.include?(method)
        bundle_options.send(method)
      else
        super
      end
    end
  end
end
