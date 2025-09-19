class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps null: false
    end

    add_index :roles, :name, unique: true
    add_index :roles, :active
  end
end
