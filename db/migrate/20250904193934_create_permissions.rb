class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions do |t|
      t.string :name, null: false
      t.string :action, null: false
      t.string :resource, null: false
      t.text :description

      t.timestamps null: false
    end

    add_index :permissions, [:action, :resource], unique: true
    add_index :permissions, :name, unique: true
  end
end
