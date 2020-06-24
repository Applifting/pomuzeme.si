require 'rails_helper'

RSpec.feature 'Organisation signs up', type: :feature do
  before do
    stub_recaptcha_key
    stub_partner_url 'https://registrace-partneru.pomuzeme.si/'
  end

  scenario 'and can click on button with new page' do
    visit home_index_path

    find_link('Registrovat organizaci').tap do |registration_link|
      expect(registration_link[:href]).to eq('https://registrace-partneru.pomuzeme.si/')
      expect(registration_link[:target]).to eq('_blank')
    end
  end
end
