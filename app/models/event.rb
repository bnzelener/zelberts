class Event < ApplicationRecord
  has_many :event_responses, dependent: :destroy

  validates :name, presence: true
  validates :date, presence: true

  default_scope { order(:sort_order, :date) }
end
