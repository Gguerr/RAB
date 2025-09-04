class CreateWorkerSizes < ActiveRecord::Migration[8.0]
  def change
    create_table :worker_sizes do |t|
      t.references :employee, null: false, foreign_key: true
      t.string :shirt_size
      t.string :shoes_size
      t.string :pants_size

      t.timestamps
    end
  end
end
