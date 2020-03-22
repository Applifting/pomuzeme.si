# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestedVolunteer, type: :model do
  context 'associations' do
    it { should belong_to(:request) }
    it { should belong_to(:volunteer) }
  end
end
