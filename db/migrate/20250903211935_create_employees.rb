class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :identification_number, null: false
      t.string :names, null: false
      t.string :surnames, null: false
      t.date :birth_date, null: false
      t.date :hire_date, null: false
      t.text :home_address
      t.date :vacation_date
      t.integer :expired_vacations, default: 0
      t.text :skills_abilities
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :employees, :identification_number, unique: true
  end
end
