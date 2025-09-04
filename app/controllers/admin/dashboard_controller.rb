class Admin::DashboardController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'
  
  def index
    @employees_count = Employee.count
    @payment_accounts_count = PaymentAccount.count
    @family_members_count = FamilyMember.count
    @recent_employees = Employee.order(created_at: :desc).limit(5)
  end
end
