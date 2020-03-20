class HomeController < ApplicationController
  def index
    session[:volunteer_id] = nil
    session[:group_id]     = nil
  end

  def partner_signup
    @partner_signup_group = Group.find_by(slug: params[:slug])

    # TODO: best replace this by "partner not found" page, now just redirecting to root
    not_found if @partner_signup_group.blank?

    session[:group_id] = @partner_signup_group.id
    render :index
  end
end
