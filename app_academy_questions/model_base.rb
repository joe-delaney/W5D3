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

  def self.get_table
    self.name.tableize
  end

end