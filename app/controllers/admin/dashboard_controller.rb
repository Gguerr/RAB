class Admin::DashboardController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'
  
  def index
    @employees_count = Employee.count
    @payment_accounts_count = PaymentAccount.count
    @family_members_count = FamilyMember.count
    @recent_employees = Employee.order(created_at: :desc).limit(5)
  end
  
  def download_manual
    manual_path = Rails.root.join('MANUAL_DE_USO.pdf')
    
    if File.exist?(manual_path)
      send_file manual_path,
                filename: 'MANUAL_DE_USO_RAB.pdf',
                type: 'application/pdf',
                disposition: 'attachment'
    else
      redirect_to admin_root_path, alert: 'El manual no está disponible en este momento.'
    end
  end
end
