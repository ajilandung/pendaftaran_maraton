class CreateRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :registrations do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :jersey_size, null: false
      t.boolean :paid, null: false, default: false
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :registrations, :email, unique: true
  end
end
