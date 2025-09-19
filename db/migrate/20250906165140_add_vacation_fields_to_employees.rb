class AddVacationFieldsToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :vacation_days, :integer
    add_column :employees, :vacation_notes, :text
  end
end
