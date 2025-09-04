class CreatePaymentAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_accounts do |t|
      t.references :employee, null: false, foreign_key: true
      t.string :account_type, null: false
      t.string :account_number
      t.string :mobile_payment_number
      t.string :bank_name
      t.boolean :is_primary, default: false
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :payment_accounts, [:employee_id, :is_primary]
  end
end
