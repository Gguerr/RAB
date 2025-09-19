require "test_helper"

class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_reports_index_url
    assert_response :success
  end

  test "should get new" do
    get admin_reports_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_reports_create_url
    assert_response :success
  end

  test "should get show" do
    get admin_reports_show_url
    assert_response :success
  end
end
