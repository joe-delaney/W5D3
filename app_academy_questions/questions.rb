require_relative 'model_base'

class Question < ModelBase
  attr_accessor :title, :body, :author_id, :id 

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
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
    @id = options['id']
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

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes 
    QuestionLike.num_likes_for_question_id(self.id)
  end

  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  # def insert
  #   QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.author_id)
  #     INSERT INTO
  #       questions (title, body, author_id)
  #     VALUES
  #       (?, ?, ?)      
  #   SQL
  #   self.id = QuestionsDatabase.instance.last_insert_row_id
  # end

  # def update
  #   QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.author_id, self.id)
  #     UPDATE
  #       questions
  #     SET
  #       title = ?,
  #       body = ?,
  #       author_id = ?
  #     WHERE
  #       id = ?
  #   SQL
  # end

end

class User < ModelBase
  attr_accessor :fname, :lname, :id 

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

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma
    average_karma = QuestionsDatabase.instance.execute(<<-SQL, self.id)
        SELECT
        (COUNT(user_like_id) / CAST(COUNT(DISTINCT(questions.id)) AS FLOAT)) AS avg_karma
         
        FROM 
          questions
        LEFT JOIN
          question_likes  ON questions.id = question_likes.question_like_id
        WHERE
          questions.author_id = ? AND question_likes.user_like_id IS NOT NULL
    SQL
    return nil if average_karma.length == 0

    average_karma.first['avg_karma']
  end

  def insert
    QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)      
    SQL
    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname, self.id)
      UPDATE
        users
      SET
        fname = ?,
        lname = ?
      WHERE
        id = ?
    SQL
  end
end

class QuestionFollow < ModelBase
  attr_accessor :id, :user_id, :question_id 

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

class Reply < ModelBase
  attr_accessor :id, :subject_question_id, :parent_reply_id, :user_id, :body 

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

  def insert
    QuestionsDatabase.instance.execute(<<-SQL, self.subject_question_id, self.parent_reply_id, self.user_id, self.body)
      INSERT INTO
        replies (subject_question_id, parent_reply_id, user_id, body)
      VALUES
        (?, ?, ?, ?)      
    SQL
    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, self.subject_question_id, self.parent_reply_id, self.user_id, self.body, self.id)
      UPDATE
        replies
      SET
        subject_question_id = ?,
        parent_reply_id = ?,
        user_id = ?,
        body = ?
      WHERE
        id = ?
    SQL
  end
end

class QuestionLike < ModelBase
  attr_accessor :id, :user_like_id, :question_like_id 

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

  def self.num_likes_for_question_id(question_id)
    count = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        question_likes
      JOIN
        users on question_likes.user_like_id = users.id
      JOIN
        questions on question_likes.question_like_id = questions.id
      WHERE
        questions.id = ?
    SQL
    return nil if count.nil?
    count.first["COUNT(*)"]
  end

  def self.liked_questions_for_user_id(user_id)
    question_like = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_likes
      JOIN
        users on question_likes.user_like_id = users.id
      JOIN
        questions on question_likes.question_like_id = questions.id
      WHERE
        users.id = ?
    SQL
    return nil if question_like.length == 0

    questions = []
    question_like.each do |question|
      questions << Question.new(question)
    end
    questions
  end

  def self.most_liked_questions(n)
    question_like = QuestionsDatabase.instance.execute(<<-SQL, n)
        SELECT
          questions.id, COUNT(*) AS numbers_likes
        FROM
          question_likes
        JOIN
          users on question_likes.user_like_id = users.id
        JOIN
          questions on question_likes.question_like_id = questions.id
        GROUP BY
          questions.id
        ORDER BY
          numbers_likes DESC
        LIMIT ?        
    SQL
    return nil if question_like.length == 0
    questions = []
    question_like.each do |question|
      questions << Question.find_by_id(question['id'])
    end
    questions
  end

  def initialize(options)
    @id = options['id']
    @user_like_id = options['user_like_id']
    @question_like_id = options['question_like_id']
  end
end