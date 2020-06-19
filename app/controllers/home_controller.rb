class HomeController < ApplicationController
  before_action :load_counts
  before_action :load_organization_logos
  before_action :load_partner_logos
  before_action :load_project_volunteers

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

  def load_organization_logos
    @organization_logos = Rails.cache.fetch :organization_logos do
      YAML.load_file('lib/assets/organization_logos.yml')
          .map(&:with_indifferent_access)
    end
  end

  def load_partner_logos
    @partner_logos = Rails.cache.fetch :partner_logos do
      YAML.load_file('lib/assets/partner_logos.yml')
          .map(&:with_indifferent_access)
    end
  end

  def load_project_volunteers
    @project_volunteers = Rails.cache.fetch :project_volunteers do
      YAML.load_file('lib/assets/project_volunteers.yml')
          .map(&:with_indifferent_access)
          .sort_by { |v| v[:name] }
    end
  end
end
