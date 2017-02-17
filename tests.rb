# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_school_has_a_term_method
    school = School.new
    assert school.respond_to?(:terms)
  end

  def test_school_has_a_term
    school = School.create
    term = Term.new
    school.terms << term
    assert school.terms.count > 0
  end

  def test_term_responds_to_school_method
    term = Term.new
    assert term.respond_to?(:school)
  end

  def test_course_has_a_school_method
    course = Course.new
    assert course.respond_to?(:school)
  end

  def test_term_cannot_be_deleted_if_courses
    term = Term.new
    course = Course.new
    term.courses << course
    term.save
    term.delete
    assert term.errors,true
  end

  def test_course_responds_to_coursestudents
    course = Course.new
    assert course.respond_to?(:course_students)
  end

  def test_coursestudent_has_a_course_method
    course_student = CourseStudent.new
    assert course_student.respond_to?(:course)
  end

  def test_cannot_delete_course_if_coursestudents
    course = Course.create(
      course_code: 42,
      name: "Ruby on Rails"
      )
    coursestudent = CourseStudent.new
    course.course_students << coursestudent
    assert course.course_students.count > 0
    refute course.destroy
  end

  def test_assignment_has_a_course_method
    assignment = Assignment.new
    assert assignment.respond_to?(:course)
  end

  def test_course_has_an_assignment_method
    course = Course.new
    assert course.respond_to?(:assignments)
  end

  # When a course is destroyed, its assignments should be automatically destroyed.
  def test_course_destroyed_means_assignments_destroyed
    course = Course.create
    assignment = Assignment.new
    course.assignments << assignment
    course.destroy
    assert course.assignments.count == 0
  end

  def test_lesson_respondsto_preclassassignt
    lesson = Lesson.new
    assert lesson.respond_to?(:pre_class_assignment)
  end

  def test_lesson_respondsto_inclassassignt
    lesson = Lesson.new
    assert lesson.respond_to?(:in_class_assignment)
  end

  def test_assignment_responds_to_lesson
    a = Assignment.new
    assert a.respond_to?(:lessons)
  end

  def test_lessons_require_name
    lesson = Lesson.create
    assert lesson.errors.any?
  end

  def test_readings_require_order_number
    reading = Reading.create
    assert reading.errors.any?
  end

  def test_readings_require_lesson_id
    reading = Reading.create
    assert reading.errors.any?
  end

  def test_readings_require_url
    reading = Reading.new
    assert reading.errors
  end

  def test_readings_OK_when_params_exist
    reading = Reading.create(
      order_number: 42,
      lesson_id: 43,
      url:  "www.google.com"
      )
    refute reading.errors.any?
  end

end
