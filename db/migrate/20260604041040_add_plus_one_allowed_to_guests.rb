class AddPlusOneAllowedToGuests < ActiveRecord::Migration[7.2]
  def change
    add_column :guests, :plus_one_allowed, :boolean, null: false, default: false
  end
end
