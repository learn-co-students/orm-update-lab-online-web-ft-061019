require_relative "../config/environment.rb"
class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def get_last_id
    sql = <<-SQL
    SELECT last_insert_rowid()
    FROM students
    SQL
    DB[:conn].execute(sql)[0][0]
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students(name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)

      @id = get_last_id
    end
  end

  def self.create(name, grade)
    self.new(name, grade).tap {|student_obj| student_obj.save }
  end

  def self.new_from_db(row)
    self.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

end
