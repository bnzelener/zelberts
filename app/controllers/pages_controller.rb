class PagesController < ApplicationController
  def home
    @events = Event.all
  end

  def weecasa
  end
end
