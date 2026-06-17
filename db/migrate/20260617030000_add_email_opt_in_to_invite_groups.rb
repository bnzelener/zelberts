class AddEmailOptInToInviteGroups < ActiveRecord::Migration[7.2]
  def up
    add_column :invite_groups, :email_opt_in, :boolean, null: false, default: false

    # Groups that already have an email on file have effectively opted in, so
    # the RSVP form pre-checks the box and keeps their address.
    execute(<<~SQL)
      UPDATE invite_groups
      SET email_opt_in = TRUE
      WHERE email IS NOT NULL AND btrim(email) <> ''
    SQL
  end

  def down
    remove_column :invite_groups, :email_opt_in
  end
end
