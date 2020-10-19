module OrganisationHelper
  def logo_with_link(organisation_symbol)
    logo = image_tag asset_path('logo/' + organisation_symbol.to_s + '.svg'), alt: translate(:alt, organisation_symbol), title: translate(:title, organisation_symbol)
    link_to logo, translate(:url, organisation_symbol), target: '_blank'
  end

  def translate(symbol, organisation_symbol)
    I18n.t "landingpage.orgs.members.#{organisation_symbol}.#{symbol}"
  end
end
