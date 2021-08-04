module Crudgen
  module Helper
    def lombok
      <<~EOF.chomp
      import lombok.AllArgsConstructor;
      import lombok.Builder;
      import lombok.Data;
      import lombok.NoArgsConstructor;

      @Data
      @Builder(toBuilder = true)
      @AllArgsConstructor
      @NoArgsConstructor
      EOF
    end

    def column_names_list
      columns.map do |column|
        format('`%s`', column.name)
      end.join(', ')
    end

    def insert_values_list
      columns.map do |column|
        column.mybatis_value_expression
      end.join(', ')
    end

    def batch_insert_values_list
      columns.map do |column|
        format('#{item.%s,jdbcType=%s}', column.lower_camel_name, column.jdbc_type)
      end.join(', ')
    end

  end
end
