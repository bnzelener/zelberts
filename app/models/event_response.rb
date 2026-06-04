class EventResponse < ApplicationRecord
  belongs_to :guest
  belongs_to :event

  validates :event_id, uniqueness: { scope: :guest_id }
end
