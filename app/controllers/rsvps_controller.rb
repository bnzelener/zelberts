class RsvpsController < ApplicationController
  def search
  end

  def results
    @query = params[:q].to_s.strip
    @groups = Guest.search_households(@query)

    case @groups.count
    when 0
      flash.now[:alert] = "We couldn't find anyone by that name. Try just your last name, or reach out to us."
      render :search
    when 1
      redirect_to form_invite_group_path(@groups.first)
    else
      render :results
    end
  end
end
