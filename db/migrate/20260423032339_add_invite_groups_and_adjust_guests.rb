class AddInviteGroupsAndAdjustGuests < ActiveRecord::Migration[7.2]
  def change
    create_table :invite_groups do |t|
      t.string :name, null: false
      t.string :address

      t.timestamps
    end

    add_reference :guests, :invite_group, foreign_key: true, index: true, null: true
    add_column :guests, :phone, :string
    remove_column :guests, :meal_choice, :string
  end
end
