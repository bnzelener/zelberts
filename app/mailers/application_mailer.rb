class ApplicationMailer < ActionMailer::Base
  # Branded sender + reply target; both override via ENV without a code change.
  # The from address must be on a domain verified in Resend; replies are routed
  # to the couple's Gmail so no inbound mail handling is needed.
  default from:     ENV.fetch("MAIL_FROM", %("Ali & Brennan" <alibrennan@zelberts.com>)),
          reply_to: ENV.fetch("MAIL_REPLY_TO", "thezelberts@gmail.com")
  layout "mailer"
end
