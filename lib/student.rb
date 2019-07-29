require_relative "../config/environment.rb"

class Student
  
  attr_accessor :name, :grade
  attr_reader :id
  
  @@all = []
  
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end 
  
  def self.all
    @@all
  end 
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER)
      SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql =  <<-SQL
     DROP TABLE IF EXISTS students
       SQL
   DB[:conn].execute(sql)
  end
  
  def save
    if self.id
      self.update 
    else 
      sql = <<-SQL
       INSERT INTO students (name, grade) 
       VALUES (?, ?)
     SQL
  
      DB[:conn].execute(sql, self.name, self.grade)
    
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
    @@all << self
  end 
  
  def update
    sql_update = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE students.id = ?;
    SQL

    DB[:conn].execute(sql_update, self.name, self.grade, self.id)
  end
  
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end
  
  def self.new_from_db(row)
    new_student = self.new(row[1], row[2], row[0])
    new_student
  end
  
  def self.find_by_name(name)
    self.all.find{|student| student.name == name}
  end
 
end
