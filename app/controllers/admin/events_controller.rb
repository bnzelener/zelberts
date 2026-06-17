class Admin::EventsController < Admin::BaseController
  before_action :set_event, only: [ :show, :edit, :update, :destroy ]

  def index
    @events = Event.all
    @attending_counts = EventResponse.where(attending: true).group(:event_id).count
  end

  def show
    @attending_guests = Guest.joins(:event_responses)
                             .where(event_responses: { event_id: @event.id, attending: true })
                             .includes(:invite_group, :plus_one_guest)
                             .order(:last_name, :first_name)
  end

  def new
    @event = Event.new(sort_order: (Event.maximum(:sort_order) || 0) + 1)
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to admin_events_path, notice: "Event created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to admin_events_path, notice: "Event updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_events_path, notice: "Event deleted."
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :date, :time, :location, :address, :description, :sort_order)
  end
end
