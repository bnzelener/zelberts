class Guest < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :attending, inclusion: { in: [ true, false ] }, on: :update

  before_save :set_responded_at, if: -> { attending_changed? && attending != nil }

  scope :attending, -> { where(attending: true) }
  scope :not_attending, -> { where(attending: false) }
  scope :pending, -> { where(attending: nil) }

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def set_responded_at
    self.responded_at = Time.current
  end
end
