class Admin::GuestsController < Admin::BaseController
  def index
    @guests = Guest.order(created_at: :desc)
    @attending_count = Guest.attending.count
    @not_attending_count = Guest.not_attending.count
    @pending_count = Guest.pending.count
  end
end
