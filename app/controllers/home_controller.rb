class HomeController < ApplicationController
  def index
    session[:volunteer] = nil
  end

  def partner
    @group = Group.find_by(slug: params[:slug])
    not_found unless @group

    session[:slug] = @group.slug
    render :index
  end
end
