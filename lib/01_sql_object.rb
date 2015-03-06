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
    raw_data = DBConnection.execute(<<-SQL)
      SELECT
      #{table_name}.*
      FROM
      #{table_name}
    SQL

    parse_all(raw_data)
  end

  def self.parse_all(results)

    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    raw_data  = DBConnection.execute(<<-SQL, id: id)
        SELECT
          #{table_name}.*
        FROM
          #{table_name}
        WHERE
          #{table_name}.id = :id
      SQL

    parse_all(raw_data).first
  end

  def initialize(params = {})
    params.each do |key, value|
        unless self.class.columns.include?(key.to_sym)
          raise "unknown attribute '#{key}'"
        end
      attributes[key.to_sym] = value
    end
  end

  def attributes
    @attributes ||= {}
  end

  def col_names
    col_array = self.class.columns.map do |col|
      col.to_s
    end

    "(#{col_array.join(', ')})"
  end

  def question_marks
    qs = ["?"] * self.class.columns.count
    "(#{qs.join(', ')})"
  end

  def col_names_for_setting
    col_array_setting = self.class.columns.map do |col|
      "#{col.to_s} = ?"
    end

    col_array_setting.join(', ')
  end

  def attribute_values
    self.class.columns.map do |col|
      attributes[col]
    end

  end

  def insert
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} #{col_names}
      VALUES
        #{question_marks}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names_for_setting}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
