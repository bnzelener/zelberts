class CreateEventResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :event_responses do |t|
      t.references :guest, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.boolean :attending, null: false, default: false

      t.timestamps
    end

    add_index :event_responses, [ :guest_id, :event_id ], unique: true
  end
end
