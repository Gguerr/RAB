class CreateFamilyMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :family_members do |t|
      t.references :employee, null: false, foreign_key: true
      t.string :names
      t.date :birth_date
      t.string :education_level
      t.string :relationship

      t.timestamps
    end
  end
end
