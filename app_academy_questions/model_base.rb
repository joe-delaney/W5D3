require 'sqlite3'
require 'singleton'
require 'active_support/inflector'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true 
    self.results_as_hash = true
  end
end

class ModelBase

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{get_table}
      WHERE
        id = ?
    SQL
    return nil if result.length == 0

    self.new(result.first)
  end

  def self.all
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{get_table} 
    SQL
    return nil if result.length == 0

    results = []
    result.each do |ele|
      results << self.new(ele)
    end
    results
  end

  def self.get_table
    self.name.tableize
  end

  def get_insert_values
    var_names = self.instance_variables
    var_values = var_names.map {|ele| self.instance_variable_get(ele)}
    var_names = var_names.map(&:to_s).map {|ele| ele[1..-1]}
    var_names[0...-1] + var_values[0...-1]
  end


  def save
    self.id ? self.update : self.insert
  end

  def insert
    QuestionsDatabase.instance.execute(<<-SQL, get_insert_values)
      INSERT INTO
        questions (?, ?, ?)
      VALUES
        (?, ?, ?)      
    SQL
    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.author_id, self.id)
      UPDATE
        questions
      SET
        title = ?,
        body = ?,
        author_id = ?
      WHERE
        id = ?
    SQL
  end

end