require 'crudboy/concerns'
module Crudboy
  module Extension
    extend ActiveSupport::Concern

    def t
      puts Terminal::Table.new { |t|
        v.each { |row| t << (row || :separator) }
      }
    end

    def v
      t = []
      t << ['Attribute Name', 'Attribute Value', 'SQL Type', 'Comment']
      t << nil
      self.class.connection.columns(self.class.table_name).each do |column|
        t << [column.name, read_attribute(column.name), column.sql_type, column.comment || '']
      end
      t
    end

    def to_insert_sql
      self.class.to_insert_sql([self])
    end

    def to_upsert_sql
      self.class.to_upsert_sql([self])
    end

    def write_csv(filename, *fields, **options)
      [self].write_csv(filename, *fields, **options)
    end

    def write_excel(filename, *fields, **options)
      [self].write_excel(filename, *fields, **options)
    end

    class_methods do
      def t
        table_name = Commands::Table::get_table_name(name)
        puts "\nTable: #{table_name}"
        puts Commands::Table::table_info_table(table_name)
      end

      def v
        table_name = Commands::Table::get_table_name(name)
        Commands::Table::table_info(table_name)
      end

      def to_insert_sql(records, batch_size = 1)
        to_sql(records, :skip, batch_size)
      end

      def to_upsert_sql(records, batch_size = 1)
        to_sql(records, :update, batch_size)
      end
    end
  end

  class Definition

    attr_accessor :table_name, :model, :model_name

    def initialize(options)
      @@options = options
      @table_name = @@options[:table_name]
      @model_name = @@options[:model_name]
      ActiveRecord::Base.connection.tap do |conn|
        Object.const_set('CrudboyModel', Class.new(ActiveRecord::Base) do
          include ::Crudboy::Concerns::TableDataDefinition
          self.abstract_class = true
        end)

        raise "Table not exist: #{@table_name}" unless conn.tables.include?(@table_name)

        table_comment = conn.table_comment(@table_name)
        conn.primary_key(@table_name).tap do |pkey|
          Class.new(::CrudboyModel) do
            include Crudboy::Extension
            self.table_name = options[:table_name]
            if pkey.is_a?(Array)
              self.primary_keys = pkey
            else
              self.primary_key = pkey
            end
            self.inheritance_column = nil
            self.default_timezone = :local
            if options[:created_at].present?
              define_singleton_method :timestamp_attributes_for_create do
                options[:created_at]
              end
            end

            if options[:updated_at].present?
              define_singleton_method :timestamp_attributes_for_update do
                options[:updated_at]
              end
            end
          end.tap do |clazz|
            Object.const_set(@model_name, clazz).tap do |const|
              @model = Model.new(const, @table_name, table_comment)
            end
          end
        end
      end
    end

    ::ActiveRecord::Relation.class_eval do
      def t(*attrs, **options)
        records.t(*attrs, **options)
      end

      def v
        records.v
      end

      def a
        to_a
      end

    end
  end
end
