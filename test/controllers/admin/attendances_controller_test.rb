require "test_helper"

class Admin::AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:one)
    @employee = employees(:one)
    @attendance = attendances(:one)
  end

  test "should get index" do
    sign_in @admin
    get admin_attendances_url
    assert_response :success
  end

  test "should get new" do
    sign_in @admin
    get new_admin_attendance_url
    assert_response :success
  end

  test "should create attendance" do
    sign_in @admin
    assert_difference('Attendance.count') do
      post admin_attendances_url, params: { 
        attendance: { 
          employee_id: @employee.id, 
          attendance_date: Date.current, 
          present: true 
        } 
      }
    end

    assert_redirected_to admin_attendances_path
  end

  test "should show attendance" do
    sign_in @admin
    get admin_attendance_url(@attendance)
    assert_response :success
  end

  test "should get edit" do
    sign_in @admin
    get edit_admin_attendance_url(@attendance)
    assert_response :success
  end

  test "should update attendance" do
    sign_in @admin
    patch admin_attendance_url(@attendance), params: { 
      attendance: { present: false } 
    }
    assert_redirected_to admin_attendances_path
  end

  test "should destroy attendance" do
    sign_in @admin
    assert_difference('Attendance.count', -1) do
      delete admin_attendance_url(@attendance)
    end

    assert_redirected_to admin_attendances_path
  end

  test "should get report" do
    sign_in @admin
    get report_admin_attendances_url(date: Date.current)
    assert_response :success
  end

  test "should get monthly_report" do
    sign_in @admin
    get monthly_report_admin_attendances_url(year: Date.current.year, month: Date.current.month)
    assert_response :success
  end

  test "should get yearly_report" do
    sign_in @admin
    get yearly_report_admin_attendances_url(year: Date.current.year)
    assert_response :success
  end
end


