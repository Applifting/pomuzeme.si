class VolunteerProfilesController < ApplicationController
  before_action :authorize_and_load_volunteer

  def show
  end

  private

  def authorize_and_load_volunteer
    @current_user = Volunteer.find(session[:volunteer_id]) if session[:volunteer_id]

    redirect_to login_path unless @current_user.present?
  end
end