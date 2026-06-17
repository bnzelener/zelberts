class Guest < ApplicationRecord
  belongs_to :invite_group, optional: true
  has_many :event_responses, dependent: :destroy

  # A plus-one is itself a Guest in the same invite group, linked back to the
  # host who is bringing them. Destroying a host removes their plus-one.
  belongs_to :plus_one_host, class_name: "Guest", optional: true
  has_one :plus_one_guest, class_name: "Guest", foreign_key: :plus_one_host_id,
          inverse_of: :plus_one_host, dependent: :destroy

  # Virtual fields backing the RSVP form's plus-one name inputs. They feed the
  # plus_one_guest record built in sync_plus_one_guest; on edit they fall back
  # to the existing record so the form pre-fills.
  attr_writer :plus_one_first_name, :plus_one_last_name

  accepts_nested_attributes_for :event_responses

  validates :first_name, presence: true
  validates :last_name, presence: true
  # Enforced only in the public RSVP flow (save(context: :rsvp)), not on
  # admin edits where a guest may legitimately still be unanswered (nil).
  validates :attending, inclusion: { in: [ true, false ] }, on: :rsvp
  validate :plus_one_name_present, on: :rsvp

  before_save :clear_declined_followups
  before_save :set_responded_at, if: -> { attending_changed? && attending != nil }
  after_save :sync_plus_one_guest

  scope :attending, -> { where(attending: true) }
  scope :not_attending, -> { where(attending: false) }
  scope :pending, -> { where(attending: nil) }
  # Guests the host party answers for directly (excludes plus-one records,
  # which are managed via their host).
  scope :primary, -> { where(plus_one_host_id: nil) }

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

  def plus_one_first_name
    return @plus_one_first_name if defined?(@plus_one_first_name)

    plus_one_guest&.first_name
  end

  def plus_one_last_name
    return @plus_one_last_name if defined?(@plus_one_last_name)

    plus_one_guest&.last_name
  end

  private

  # The plus-one's name is required once a host commits to bringing one.
  def plus_one_name_present
    return unless plus_one_host_id.nil?
    return unless plus_one && plus_one_allowed && attending == true

    if plus_one_first_name.blank? || plus_one_last_name.blank?
      errors.add(:base, "Please enter your guest's first and last name")
    end
  end

  # Reconcile the linked plus-one Guest record with the host's answers: create
  # or update it when the host is bringing one, otherwise remove it. Runs only
  # for hosts (plus_one_host_id nil) so it never recurses through the plus-one's
  # own save. clear_declined_followups has already forced plus_one to false when
  # the host isn't attending or lacks permission.
  def sync_plus_one_guest
    return unless plus_one_host_id.nil?

    if plus_one && plus_one_first_name.present? && plus_one_last_name.present?
      guest = plus_one_guest || build_plus_one_guest
      guest.invite_group = invite_group
      guest.first_name = plus_one_first_name
      guest.last_name = plus_one_last_name
      guest.attending = true
      guest.save!
      sync_plus_one_events(guest)
    elsif plus_one_guest
      plus_one_guest.destroy!
    end
  end

  # The plus-one attends whatever events the host selected.
  def sync_plus_one_events(guest)
    event_ids = event_responses.select { |er| er.attending && er.event_id }.map(&:event_id)
    guest.event_responses.where.not(event_id: event_ids).destroy_all
    event_ids.each do |event_id|
      guest.event_responses.find_or_initialize_by(event_id: event_id).update!(attending: true)
    end
  end

  # Server-side guard (independent of the form's JS): a guest who isn't
  # attending can't have follow-up answers, and a guest without plus-one
  # permission can't bring one.
  def clear_declined_followups
    unless attending == true
      self.plus_one = false
      event_responses.each { |er| er.attending = false }
    end

    self.plus_one = false unless plus_one_allowed
  end

  def set_responded_at
    self.responded_at = Time.current
  end
end
