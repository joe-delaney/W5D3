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

class Question 
  attr_accessor :title, :body, :author_id, :id 

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

  def self.find_by_author_id(author_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions 
      WHERE
        author_id = ?
    SQL
    return nil if question.length == 0

    Question.new(question.first)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
end

class User 
  attr_accessor :fname, :lname, :id 

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users 
      WHERE
        id = ?
    SQL
    return nil if user.length == 0

    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
end

class QuestionFollow 
  attr_accessor :id, :user_id, :question_id 

  def self.find_by_id(id)
    question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows 
      WHERE
        id = ?
    SQL
    return nil if question_follow.length == 0

    QuestionFollow.new(question_follow.first)
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end

class Reply 
  attr_accessor :id, :subject_question_id, :parent_reply_id, :user_id, :body 

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies 
      WHERE
        id = ?
    SQL
    return nil if reply.length == 0

    Reply.new(reply.first)
  end

  def initialize(options)
    @id = options['id']
    @subject_question_id = options['subject_question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end
end

class QuestionLike
  attr_accessor :id, :user_like_id, :question_like_id 

  def self.find_by_id(id)
    question_like= QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil if question_like.length == 0

    QuestionLike.new(question_like.first)
  end


  def initialize(options)
    @id = options['id']
    @user_like_id = options['user_like_id']
    @question_like_id = options['question_like_id']
  end
end