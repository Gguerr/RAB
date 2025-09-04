class PaymentAccount < ApplicationRecord
  belongs_to :employee

  # Validations
  validates :account_type, presence: true, inclusion: { in: %w[bank mobile_payment] }
  validates :account_number, presence: true, if: -> { account_type == 'bank' }
  validates :mobile_payment_number, presence: true, if: -> { account_type == 'mobile_payment' }
  validates :bank_name, presence: true, if: -> { account_type == 'bank' }

  # Scopes
  scope :primary, -> { where(is_primary: true) }
  scope :bank_accounts, -> { where(account_type: 'bank') }
  scope :mobile_payments, -> { where(account_type: 'mobile_payment') }
end
