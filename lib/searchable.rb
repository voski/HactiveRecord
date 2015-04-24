require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    raw_data = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line(params)}
    SQL

    parse_all(raw_data)
  end

  def where_line(params)
    where_line = params.keys.map do |key|
      "#{key} = ?"
    end.join(' AND ')
  end
end

class SQLObject
  extend Searchable
end
