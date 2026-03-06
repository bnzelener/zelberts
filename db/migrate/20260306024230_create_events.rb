class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :name
      t.date :date
      t.string :time
      t.string :location
      t.string :address
      t.text :description
      t.integer :sort_order

      t.timestamps
    end
  end
end
