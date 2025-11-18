class AddWorkLocationToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :work_location, :string
  end
end
