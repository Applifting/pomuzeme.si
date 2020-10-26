class HomeController < PublicController
  skip_before_action :authorize_current_volunteer
  before_action :load_counts

  def index
    session[:volunteer_id] = nil
    session[:group_id]     = nil

    @requests            = Request.for_web.limit(3).decorate
    @all_requests_count  = Request.for_web.count
    @news                = News.cached_recent_news(5)
    @publications        = News.cached_recent_from_media(5)
  end

  def need_volunteers
  end

  def partner_signup
    @partner_signup_group = Group.find_by(slug: params[:slug])

    # TODO: best replace this by "partner not found" page, now just redirecting to root
    not_found if @partner_signup_group.blank?

    session[:group_id] = @partner_signup_group.id
    render :partner_signup, layout: 'public'
  end

  private

  def load_counts
    @volunteer_count      = Volunteer.cached_count
    @organisations_count  = Organisation.cached_count
  end
end
