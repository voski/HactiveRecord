require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    raw_data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    raw_data.first.map do |col|
      col.to_sym
    end
  end

  def self.finalize!
    columns.each do |col_sym|
      define_method( "#{col_sym.to_s}" ) do
        attributes[col_sym]
      end

      define_method( "#{col_sym.to_s}=" ) do |val|
        # instance_variable_set("@#{col_sym.to_s}", val)
        attributes[col_sym] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self}".tableize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})

    params.each do |key, value|

        unless self.class.columns.include?(key.to_sym)
          raise "unknown attribute '#{key}'"
        end
      attributes[key] = value
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
