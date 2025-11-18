require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  def setup
    @employee = employees(:one)
    @attendance = Attendance.new(
      employee: @employee,
      attendance_date: Date.current,
      present: true
    )
  end

  test "should be valid" do
    assert @attendance.valid?
  end

  test "should require employee" do
    @attendance.employee = nil
    assert_not @attendance.valid?
  end

  test "should require attendance_date" do
    @attendance.attendance_date = nil
    assert_not @attendance.valid?
  end

  test "should have unique employee per date" do
    @attendance.save
    duplicate_attendance = Attendance.new(
      employee: @employee,
      attendance_date: @attendance.attendance_date,
      present: false
    )
    assert_not duplicate_attendance.valid?
  end

  test "should default present to false" do
    attendance = Attendance.new(employee: @employee, attendance_date: Date.current)
    assert_not attendance.present?
  end

  test "should belong to employee" do
    assert_respond_to @attendance, :employee
  end

  test "for_date scope should work" do
    @attendance.save
    attendances = Attendance.for_date(Date.current)
    assert_includes attendances, @attendance
  end

  test "present scope should work" do
    @attendance.save
    present_attendances = Attendance.present
    assert_includes present_attendances, @attendance
  end

  test "absent scope should work" do
    @attendance.present = false
    @attendance.save
    absent_attendances = Attendance.absent
    assert_includes absent_attendances, @attendance
  end
end


