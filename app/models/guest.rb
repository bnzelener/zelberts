class Guest < ApplicationRecord
  belongs_to :invite_group, optional: true
  has_many :event_responses, dependent: :destroy

  accepts_nested_attributes_for :event_responses

  validates :first_name, presence: true
  validates :last_name, presence: true
  # Enforced only in the public RSVP flow (save(context: :rsvp)), not on
  # admin edits where a guest may legitimately still be unanswered (nil).
  validates :attending, inclusion: { in: [ true, false ] }, on: :rsvp

  before_save :clear_declined_followups
  before_save :set_responded_at, if: -> { attending_changed? && attending != nil }

  scope :attending, -> { where(attending: true) }
  scope :not_attending, -> { where(attending: false) }
  scope :pending, -> { where(attending: nil) }

  # Admin search across guest name (first, last, or "first last") and the
  # guest's invite group email.
  scope :search, ->(query) {
    term = "%#{query.to_s.strip.downcase}%"
    left_joins(:invite_group).where(
      "lower(guests.first_name) LIKE :t OR lower(guests.last_name) LIKE :t OR " \
      "lower(guests.first_name || ' ' || guests.last_name) LIKE :t OR " \
      "lower(invite_groups.email) LIKE :t",
      t: term
    )
  }

  # Find the invite groups (households) matching a typed name.
  # Tries an exact "first last" match; if none, falls back to a last-name
  # prefix using the final word of the query. Guests without a household are
  # excluded since the RSVP flow is keyed on the invite group.
  def self.search_households(query)
    q = query.to_s.strip.downcase
    return InviteGroup.none if q.blank?

    matches = grouped.where("lower(first_name || ' ' || last_name) = ?", q)
    if matches.none?
      last = q.split.last
      matches = grouped.where("lower(last_name) LIKE ?", "#{last}%")
    end

    InviteGroup.where(id: matches.select(:invite_group_id))
  end

  def self.grouped
    where.not(invite_group_id: nil)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  # Server-side guard (independent of the form's JS): a guest who isn't
  # attending can't have follow-up answers, and a guest without plus-one
  # permission can't bring one.
  def clear_declined_followups
    unless attending == true
      self.plus_one = false
      self.plus_one_name = nil
      event_responses.each { |er| er.attending = false }
    end

    unless plus_one_allowed
      self.plus_one = false
      self.plus_one_name = nil
    end
  end

  def set_responded_at
    self.responded_at = Time.current
  end
end
