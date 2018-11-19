module InsertMultiple
  extend ActiveSupport::Concern

  module ClassMethods
    def insert_multiple(fields, values)
      if fields.any? && values.any?
        connection.insert(sanitize_sql(sanitize_arrays(fields, values)))
      end
    end

    private
    def sanitize_arrays(fields, values)
      question_signs = wrap_parentheses(strings_by_comma('?', fields.size))
      question_signs = strings_by_comma(question_signs, values.size)

      ["INSERT INTO #{table_name} (#{fields.join(', ')}) VALUES #{question_signs}", *values.flatten]
    end

    def wrap_parentheses(str)
      str.prepend('(').concat(')')
    end

    def strings_by_comma(str, size)
      Array.new(size, str).join(', ')
    end
  end
end
