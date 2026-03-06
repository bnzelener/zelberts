class Event < ApplicationRecord
  validates :name, presence: true
  validates :date, presence: true

  default_scope { order(:sort_order, :date) }
end
