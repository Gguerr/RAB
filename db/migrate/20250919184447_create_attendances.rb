class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :attendance_date, null: false
      t.boolean :present, default: false
      t.text :signature
      t.text :notes

      t.timestamps
    end

    add_index :attendances, [:employee_id, :attendance_date], unique: true
    add_index :attendances, :attendance_date
  end
end
