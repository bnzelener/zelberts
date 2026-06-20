class ApplicationMailer < ActionMailer::Base
  # Branded sender; override via ENV so it can point at the verified Resend
  # domain without a code change. Must be on a domain verified in Resend.
  default from: ENV.fetch("MAIL_FROM", %("Ali & Brennan" <hello@example.com>))
  layout "mailer"
end
