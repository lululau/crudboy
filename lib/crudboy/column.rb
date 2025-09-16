module Crudboy
  class Column

    JAVA_TYPES = {
      "varchar" => 'String',
      "char" => 'String',
      "text" => 'String',
      "longtext" => 'String',
      "int" => 'Integer',
      "smallint" => 'Integer',
      "bigint" => 'Long',
      "tinyint" => 'Byte',
      "double" => 'Double',
      "date" => 'LocalDate',
      "datetime" => 'LocalDateTime',
      "timestamp" => 'LocalDateTime',
      "time" => 'LocalTime',
      "blob" => 'byte[]',
      "decimal" => 'BigDecimal'
    }

    JDBC_TYPES = {
      "varchar" => 'VARCHAR',
      "char" => 'CHAR',
      "text" => 'VARCHAR',
      "longtext" => 'VARCHAR',
      "int" => 'INTEGER',
      "smallint" => 'INTEGER',
      "bigint" => 'BIGINT',
      "tinyint" => 'TINYINT',
      "double" => 'DOUBLE',
      "date" => 'TIMESTAMP',
      "datetime" => 'TIMESTAMP',
      "timestamp" => 'TIMESTAMP',
      "time" => 'TIME',
      "blob" => 'BLOB',
      "decimal" => 'DECIMAL'
    }

    PYTHON_TYPES = {
      "varchar" => 'str',
      "char" => 'str',
      "text" => 'str',
      "longtext" => 'str',
      "int" => 'int',
      "smallint" => 'int',
      "bigint" => 'int',
      "tinyint" => 'int',
      "double" => 'float',
      "date" => 'datetime',
      "datetime" => 'datetime',
      "timestamp" => 'datetime',
      "time" => 'datetime',
      "blob" => 'bytes',
      "decimal" => 'decimal'
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

    def python_type
      raw_type = sql_type.scan(/^\w+/).first
      PYTHON_TYPES[raw_type]
    end

    def python_type_with_optional
      raw_python_type = python_type
      null ? "Optional[#{raw_python_type}]" : raw_python_type
    end

    def py_sqlmodel_primary_column_declaration
      format('%s: %s = Field(default_factory=gen_id, primary_key=True, max_length=%s, description="%s")', name, python_type, limit, comment)
    end

    def py_dto_column_declaration(optional = false)
      # for example:     id: str = Field(description="ID")
      if optional
        format('%s: %s | None = Field(description="%s", default=None)', name, python_type, comment)
      else
        format('%s: %s = Field(description="%s")', name, python_type, comment)
      end
    end

    def py_sqlmodel_regular_column_declaration
      if created_at_column?
        return py_sqlmodel_created_at_column_declaration
      end

      if updated_at_column?
        return py_sqlmodel_updated_at_column_declaration
      end

      format('%s: %s = Field(default=None, max_length=%s, description="%s")', name, python_type_with_optional, limit || 'None', comment || '')
    end

    def py_sqlmodel_created_at_column_declaration
      #  create_time: Optional[datetime] = Field(
      #     default_factory=datetime.now,
      #     description="Create Time",
      #     sa_column_kwargs={"server_default": sa.func.now()},
      # )
      format('%s: %s = Field(default_factory=datetime.now, description="%s", sa_column_kwargs={"server_default": sa.func.now()})', name, python_type_with_optional, comment || '')
    end

    def py_sqlmodel_updated_at_column_declaration
      #  update_time: Optional[datetime] = Field(
      #     default_factory=datetime.now,
      #     description="Update Time",
      #     sa_column_kwargs={"server_default": sa.func.now()},
      # )
      format('%s: %s = Field(default_factory=datetime.now, description="%s", sa_column_kwargs={"server_default": sa.func.now()})', name, python_type_with_optional, comment || '')
    end

    def created_at_column?
      sql_type =~ /datetime|time|date|timestamp/ && name =~ /gmt_created|created_at|create_time|create_date/
    end

    def updated_at_column?
      sql_type =~ /datetime|time|date|timestamp/ && name =~ /gmt_modified|updated_at|update_time|update_date/
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
