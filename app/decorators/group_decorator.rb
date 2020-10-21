class GroupDecorator < ApplicationDecorator
  delegate_all

  def slug
    url = "https://pomuzeme.si/#{object.slug}"
    h.link_to url, url, target: '_blank'
  end
end
