class RemoveAddressFromInviteGroups < ActiveRecord::Migration[7.2]
  def change
    remove_column :invite_groups, :address, :string
  end
end
