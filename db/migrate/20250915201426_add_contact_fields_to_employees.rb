class AddContactFieldsToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :email, :string
    add_column :employees, :phone_number, :string
    add_column :employees, :position, :string
    add_column :employees, :code, :string
    add_column :employees, :voting_center, :string
  end
end
