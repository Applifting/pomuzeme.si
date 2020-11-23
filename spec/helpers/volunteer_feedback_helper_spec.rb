# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VolunteerFeedback::Helper do
  let(:helper) { double('helper') }

  before do
    helper.extend(VolunteerFeedback::Helper)
  end

  describe 'permitted_interpolations' do
    it 'lists permitted interpolation keys' do
      expect(helper.permitted_interpolations).to include 'prijimajici_organizace'
    end
  end

  describe 'extract_interpolations' do
    let(:text) { 'Some text %{containing} some %{interpolations}' }

    it 'extracts %{interpolations} from text' do
      expect(helper.extract_interpolations(text).sort).to eq %w[containing interpolations].sort
    end
  end

  describe 'interpolate_message' do
    let(:request)             { create :request, subscriber_organisation: 'Ironman'}
    let(:requested_volunteer) { create :requested_volunteer, request: request }
    let(:message) { 'This is coming from %{prijimajici_organizace}' }

    it 'fills in the permitted interpolations from requested_volunteer into the message' do
      expect(helper.interpolate_message(message, requested_volunteer)).to eq 'This is coming from Ironman'
    end
  end
end