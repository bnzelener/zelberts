class AddWelcomeDrinksEndTime < ActiveRecord::Migration[7.2]
  def up
    execute "UPDATE events SET time = '7:30 PM - 10:00 PM' WHERE name = 'Welcome Drinks'"
  end

  def down
    execute "UPDATE events SET time = '7:30 PM' WHERE name = 'Welcome Drinks'"
  end
end
