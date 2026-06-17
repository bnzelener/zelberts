class InviteGroup < ApplicationRecord
  has_many :guests, dependent: :destroy

  accepts_nested_attributes_for :guests

  validates :name, presence: true
  validates :email, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # In the public RSVP flow, a party opting into email updates must give an
  # address. Admin edits aren't held to this.
  validates :email, presence: true, if: :email_opt_in, on: :rsvp
end
