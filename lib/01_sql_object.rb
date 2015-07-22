require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    result = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    result.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column_name|
      define_method("#{column_name.to_s}") do
        attributes[column_name]
      end
    end

    columns.each do |column_name|
      define_method("#{column_name.to_s}=") do |value|
        attributes[column_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    instance_variable_set("@table_name", table_name)
  end

  def self.table_name
    if instance_variable_get("@table_name").nil?
      self.table_name = self.to_s.pluralize.downcase
    end
    instance_variable_get("@table_name")
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    parse_all(rows)
  end

  def self.parse_all(results)
    results.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = #{id}
    SQL
    return nil if rows.empty?
    cat = self.new(rows.first)
  end

  def initialize(params = {})
    valid_columns = self.class.columns
    params.keys.each do |given_col|
      unless valid_columns.include?(given_col.to_sym) 
        raise Exception.new "unknown attribute '#{given_col}'"
      end
      send("#{given_col}=", params[given_col])
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    cols_string = "#{attributes.keys.join(", ")}"
    rows = DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{cols_string})
      VALUES
        (#{[["?"]*(attribute_values.length)].join(",")})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    cols_array = attributes.keys.map {|col| col.to_s + " = ? "}
    cols_string = cols_array.join(", ")
    rows = DBConnection.execute(<<-SQL, attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{cols_string}
      WHERE
        id = ?
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def save
    if (self.id).nil?
      self.insert
    else
      self.update
    end

  end
end
