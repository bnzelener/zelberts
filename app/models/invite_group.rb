class InviteGroup < ApplicationRecord
  has_many :guests, dependent: :destroy

  accepts_nested_attributes_for :guests

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
