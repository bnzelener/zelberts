# Preview RSVP emails in the browser while iterating on the design.
# Visit http://localhost:3000/rails/mailers/rsvp_mailer/confirmation
class RsvpMailerPreview < ActionMailer::Preview
  def confirmation
    group = InviteGroup.where.not(email: nil).first || InviteGroup.first
    RsvpMailer.confirmation(group)
  end
end
