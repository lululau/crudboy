module Crudboy
  class Model
    attr_accessor :active_record_model, :name, :table_name, :table_comment, :columns

    def initialize(active_record_model, table_name, table_comment)
      @active_record_model = active_record_model
      @name = @active_record_model.name
      @table_name = table_name
      @table_comment = table_comment
      @columns = active_record_model.columns.map { |c| Column.new(c, c.name == active_record_model.primary_key) }
    end

    def primary_column
      columns.find { |c| c.name == active_record_model.primary_key }
    end

    def regular_columns
      columns.reject { |c| c.name == active_record_model.primary_key }
    end

    def columns(**options)
      if options.empty?
        @columns
      elsif options[:except]
        @columns.reject do |column|
          if options[:except].is_a?(Array)
            options[:except].include?(column.name)
          elsif options[:except].is_a?(Regexp)
            column.name =~ options[:except]
          else
            false
          end
        end
      elsif options[:only]
        @columns.select do |column|
          if options[:only].is_a?(Array)
            options[:only].include?(column.name)
          elsif options[:only].is_a?(Regexp)
            column.name =~ options[:only]
          else
            true
          end
        end
      end
    end

    def method_missing(method, *args, **options, &block)
      if active_record_model.respond_to?(method)
        active_record_model.send(method, *args, **options, &block)
      else
        super
      end
    end
  end
end
