class PublicController < ApplicationController
  before_action :load_current_volunteer
  before_action :authorize_current_volunteer

  attr_accessor :current_volunteer

  private

  def load_current_volunteer
    @current_volunteer = Volunteer.find(session[:volunteer_id]) if session[:volunteer_id]
  end

  def set_raven_context
    Raven.user_context(current_volunteer_id: current_volunteer&.id) if current_volunteer
  end

  def authorize_current_volunteer
    redirect_to login_path unless @current_volunteer.present?
  end
end
