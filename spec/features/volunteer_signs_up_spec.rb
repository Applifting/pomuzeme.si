require 'rails_helper'

RSpec.feature "Volunteer signs up", type: :feature do
  before do
    stub_recaptcha_key
  end

  scenario 'and can see registration modal' do
    # TODO: fix capybara to handle JS
    visit home_index_path

    first(:button, "Chci pomáhat").click

    expect(page).to have_text('Zaregistrovat se')
  end
end
