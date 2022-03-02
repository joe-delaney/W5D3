-- PRAGMA foreign_keys = ON;

DROP TABLE if EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE if EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY(author_id) REFERENCES users(id)
);

DROP TABLE if EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

DROP TABLE if EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  subject_question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body VARCHAR(255),

  FOREIGN KEY(subject_question_id) REFERENCES questions(id),
  FOREIGN KEY(parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

DROP TABLE if EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_like_id INTEGER NOT NULL,
  question_like_id INTEGER NOT NULL,

  FOREIGN KEY(user_like_id) REFERENCES users(id),
  FOREIGN KEY(question_like_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Ned', 'Delaney'),
  ('Kush', 'Shih'),
  ('Earl', 'Meou')
  ;

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Ned Question', 'NED NED NED' , (SELECT id from users where fname = 'Ned')),
  ('Kush Question', 'KUSH KUSH K' , (SELECT id from users where fname = 'Kush')),
  ('Earl Question', 'MEOW MEOW M' , (SELECT id from users where fname = 'Earl')); 

INSERT INTO
  replies (subject_question_id, parent_reply_id, user_id, body)
VALUES
  (1, NULL, 1, "TEST 1 ---USER1"),
  (1, 1, 2, "TEST 1  ---USER2"),
  (2, NULL, 3, "TEST 2  ---USER3"),
  (2, 3, 2, "TEST 2  ---USER2");

INSERT INTO 
  question_follows(id, user_id, question_id)
VALUES 
  (1,1,1),
  (2,2,1),
  (3,2,2),
  (4,1,2),
  (5,3,2),
  (6,2,3);

INSERT INTO 
  question_likes(id, user_like_id, question_like_id)
VALUES 
  (1,1,1),
  (2,2,1),
  (3,2,2),
  (4,3,2);