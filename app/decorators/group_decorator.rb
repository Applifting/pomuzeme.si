class GroupDecorator < ApplicationDecorator
  delegate_all

  def slug
    url = "https://pomuzeme.si/#{object.slug}"
    h.link_to url, url, target: '_blank'
  end

  def signup_partial
    signup_partial_name.present? ? "home/partials/partners/#{signup_partial_name}" : 'home/partials/section_partner_channel'
  end
end
