require 'sqlite3'
require 'singleton'

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
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions 
      WHERE
        id = ?
    SQL
    return nil if question.length == 0

    Question.new(question.first)
  end


end