class CreatePartyCards < ActiveRecord::Migration[8.0]
  def change
    create_table :party_cards do |t|
      t.references :employee, null: false, foreign_key: true
      t.string :code
      t.string :serial_number

      t.timestamps
    end
  end
end
