class MoveEmailFromGuestsToInviteGroups < ActiveRecord::Migration[7.2]
  def change
    add_column :invite_groups, :email, :string
    remove_column :guests, :email, :string
  end
end
