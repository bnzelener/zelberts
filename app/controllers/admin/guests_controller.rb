class Admin::GuestsController < ApplicationController
  # TODO: Add authentication (http_basic_authenticate_with or Devise)

  def index
    @guests = Guest.order(created_at: :desc)
    @attending_count = Guest.attending.count
    @not_attending_count = Guest.not_attending.count
    @pending_count = Guest.pending.count
  end
end
