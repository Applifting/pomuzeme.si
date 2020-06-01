class HomeController < ApplicationController
  before_action :load_counts

  def index
    session[:volunteer_id] = nil
    session[:group_id]     = nil

    @news                = News.cached_recent_news(5)
    @publications        = News.cached_recent_from_media(5)
  end

  def partner_signup
    @partner_signup_group = Group.find_by(slug: params[:slug])

    # TODO: best replace this by "partner not found" page, now just redirecting to root
    not_found if @partner_signup_group.blank?

    session[:group_id] = @partner_signup_group.id
    render :index
  end

  private

  def load_counts
    @volunteer_count      = Volunteer.cached_count
    @organisations_count  = Organisation.cached_count
  end
end
