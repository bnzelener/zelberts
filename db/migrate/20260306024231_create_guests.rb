class CreateGuests < ActiveRecord::Migration[7.2]
  def change
    create_table :guests do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :attending
      t.string :meal_choice
      t.text :dietary_notes
      t.boolean :plus_one
      t.string :plus_one_name
      t.text :message
      t.datetime :responded_at

      t.timestamps
    end
  end
end
