class RsvpsController < ApplicationController
  def new
    @guest = Guest.new
  end

  def create
    @guest = Guest.new(guest_params)

    if @guest.save
      redirect_to rsvp_path(@guest), notice: "Thank you for your RSVP!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @guest = Guest.find(params[:id])
  end

  private

  def guest_params
    params.require(:guest).permit(
      :first_name, :last_name, :email, :attending,
      :meal_choice, :dietary_notes, :plus_one, :plus_one_name, :message
    )
  end
end
