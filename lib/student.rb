require 'pry'
class Student
  attr_accessor :id, :name, :grade

  @@all = []

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    new_student = Student.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM students
    SQL

    DB[:conn].execute(sql).collect do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL

    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  # returns an array of all students in grades 9
  def self.all_students_in_grade_9
    sql = <<-SQL
      SELECT name FROM students WHERE grade = 9
    SQL

    self.all.select do |student_instance|
      DB[:conn].execute(sql).flatten.include?(student_instance.name)      
    end
  end

  # returns an array of all students in grades 11 or below
  def self.students_below_12th_grade
    sql = <<-SQL
      SELECT name FROM students WHERE grade < 12
    SQL

    self.all.select do |student_instance|
      DB[:conn].execute(sql).flatten.include?(student_instance.name)      
    end
  end
  
  # returns an array of the first X students in grade 10
  def self.first_X_students_in_grade_10(num_students)
    sql = <<-SQL
      SELECT name FROM students WHERE grade = 10 LIMIT ?
    SQL

    self.all.select do |student_instance|
      DB[:conn].execute(sql, num_students).flatten.include?(student_instance.name)      
    end
  end

  # returns the first student in grade 10
  def self.first_student_in_grade_10
    sql = <<-SQL
      SELECT name FROM students WHERE grade = 10 LIMIT 1
    SQL

    self.all.select do |student_instance|
      DB[:conn].execute(sql).flatten.include?(student_instance.name)
    end.first
  end

  # returns an array of all students in a given grade X
  def self.all_students_in_grade_X(grade)
    sql = <<-SQL
      SELECT name FROM students WHERE grade = ?
    SQL

    self.all.select do |student_instance|
      DB[:conn].execute(sql, grade).flatten.include?(student_instance.name)
    end
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
