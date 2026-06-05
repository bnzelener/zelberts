class AddWeecasaToInviteGroups < ActiveRecord::Migration[7.2]
  def change
    # Admin-set flag: is this group part of the WeeCasa tiny-home block?
    add_column :invite_groups, :weecasa_included, :boolean, default: false, null: false
    # Group's RSVP answer to "do you want to stay in the tiny homes?" (nil = unanswered)
    add_column :invite_groups, :weecasa_response, :boolean
  end
end
