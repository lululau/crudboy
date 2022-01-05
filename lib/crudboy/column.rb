module Crudboy
  class Column

    JAVA_TYPES = {
      "varchar" => 'String',
      "char" => 'String',
      "text" => 'String',
      "int" => 'Integer',
      "bigint" => 'Long',
      "tinyint" => 'Byte',
      "date" => 'LocalDate',
      "datetime" => 'LocalDateTime',
      "timestamp" => 'LocalDateTime',
      "decimal" => 'BigDecimal'
    }

    JDBC_TYPES = {
      "varchar" => 'VARCHAR',
      "char" => 'CHAR',
      "text" => 'TEXT',
      "int" => 'INTEGER',
      "bigint" => 'BIGINT',
      "tinyint" => 'TINYINT',
      "date" => 'TIMESTAMP',
      "datetime" => 'TIMESTAMP',
      "timestamp" => 'TIMESTAMP',
      "decimal" => 'DECIMAL'
    }

    attr_accessor :active_record_column, :primary

    def initialize(column, primary)
      @active_record_column = column
      @primary = primary
    end

    def java_doc
      <<-EOF.lstrip.chomp
      /**
     * #{comment}
     */
      EOF
    end

    def mybatis_value_expression
      format('#{%s,jdbcType=%s}', lower_camel_name, jdbc_type)
    end

    def mybatis_equation
      format('`%s` = %s', name, mybatis_value_expression)
    end

    def mybatis_result_map
      if @primary
        format('<id column="%s" jdbcType="%s" property="%s" />', name, jdbc_type, lower_camel_name)
      else
        format('<result column="%s" jdbcType="%s" property="%s" />', name, jdbc_type, lower_camel_name)
      end
    end

    def lower_camel_name
      name.camelcase(:lower)
    end

    def upper_camel_name
      name.camelcase(:upper)
    end

    def java_type
      return 'Boolean' if sql_type == 'tinyint(1)'
      raw_type = sql_type.scan(/^\w+/).first
      JAVA_TYPES[raw_type]
    end

    def jdbc_type
      raw_type = sql_type.scan(/^\w+/).first
      JDBC_TYPES[raw_type]
    end

    def method_missing(method, *args, **options, &block)
      if active_record_column.respond_to?(method)
        active_record_column.send(method, *args, **options, &block)
      else
        super
      end
    end
  end
end
