class AddSpecificGradeToFamilyMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :family_members, :specific_grade, :string
  end
end
