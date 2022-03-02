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

    questions = []
    question.each do |ele|
      questions << Question.new(ele)
    end
    questions 
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author 
    User.find_by_id(self.author_id)
  end

  def replies
    Reply.find_by_question_id(self.id)    
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
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

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users 
      WHERE
        fname = ? AND lname =?
    SQL
    return nil if user.length == 0

    users = []
    user.each do |ele|
      users << User.new(ele)
    end
    users
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followers_for_user_id(self.id)
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

  def self.followers_for_question_id(question_id)
    question_follow = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_follows
      JOIN
        users on question_follows.user_id = users.id
      JOIN
        questions on question_follows.question_id = questions.id
      WHERE
        questions.id = ?
    SQL
    return nil if question_follow.length == 0

    users = []
    question_follow.each do |user|
      users << User.new(user)
    end
    users
  end

  def self.followers_for_user_id(user_id)
    question_follow = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_follows
      JOIN
        users on question_follows.user_id = users.id
      JOIN
        questions on question_follows.question_id = questions.id
      WHERE
        users.id = ?
    SQL
    return nil if question_follow.length == 0

    questions = []
    question_follow.each do |question|
      questions << Question.new(question)
    end
    questions
  end 

  def self.most_followed_questions(n)
    question_follow = QuestionsDatabase.instance.execute(<<-SQL, n)
        SELECT
          questions.id, COUNT(*) AS numbers_followers
        FROM
          question_follows
        JOIN
          users on question_follows.user_id = users.id
        JOIN
          questions on question_follows.question_id = questions.id
        GROUP BY
          questions.id
        ORDER BY
          numbers_followers DESC
        LIMIT ?        
    SQL
    return nil if question_follow.length == 0
    questions = []
    question_follow.each do |question|
      questions << Question.find_by_id(question['id'])
    end
    questions
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

  def self.find_by_user_id(user_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies 
      WHERE
        user_id = ?
    SQL
    return nil if reply.length == 0

    replies = []
    reply.each do |ele|
      replies << Reply.new(ele)
    end
    replies 
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies 
      WHERE
        subject_question_id = ?
    SQL
    return nil if reply.length == 0

    replies = []
    reply.each do |ele|
      replies << Reply.new(ele)
    end
    replies 
  end

  def initialize(options)
    @id = options['id']
    @subject_question_id = options['subject_question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    User.find_by_id(self.user_id)
  end

  def question
    Question.find_by_id(self.subject_question_id)
  end

  def parent_reply
    Reply.find_by_id(self.parent_reply_id)
  end

  def child_replies
    reply = QuestionsDatabase.instance.execute(<<-SQL, self.id)
    SELECT
      *
    FROM
      replies 
    WHERE
      parent_reply_id = ?
    SQL

    return nil if reply.length == 0
    replies = []
    reply.each do |ele|
      replies << Reply.new(ele)
    end
    replies 

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

  def self.likers_for_question_id(question_id)
    question_like = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_likes
      JOIN
        users on question_likes.user_like_id = users.id
      JOIN
        questions on question_likes.question_like_id = questions.id
      WHERE
        questions.id = ?
    SQL
    return nil if question_like.length == 0

    users = []
    question_like.each do |user|
      users << User.new(user)
    end
    users

  end


  def initialize(options)
    @id = options['id']
    @user_like_id = options['user_like_id']
    @question_like_id = options['question_like_id']
  end
end