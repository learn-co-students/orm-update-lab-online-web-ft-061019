require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  @@all = []

  def initialize(id=nil, name, grade)
    @id = id
    self.name = name
    self.grade = grade
  end
  
  def self.create_table
    sql_create = <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL

    DB[:conn].execute(sql_create)
  end
  
  def self.drop_table
    sql_drop = <<-SQL
      DROP TABLE students;
    SQL

    DB[:conn].execute(sql_drop)
  end

  def save
    if self.id
      self.update
    else
      sql_save = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?);
      SQL

      DB[:conn].execute(sql_save, self.name, self.grade)

      sql_id = <<-SQL
        SELECT last_insert_rowid() FROM students;
      SQL

      @id = DB[:conn].execute(sql_id)[0][0]
      @@all << self
    end
  end
  
  def update
    sql_update = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE students.id = ?;
    SQL

    DB[:conn].execute(sql_update, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end
  
  def self.new_from_db(row)
    id, name, grade = row
    new_student = Student.new(id, name, grade)
  end

  def self.find_by_name(name)
    self.all.find {|student_obj| student_obj.name == name}
  end

  def self.all
    @@all
  end


end
