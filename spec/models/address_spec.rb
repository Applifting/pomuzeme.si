# frozen_string_literal: true

require 'rails_helper'
require 'support/geocoder_helper'

RSpec.describe Address, type: :model do
  include GeocoderHelper

  context 'validations' do
    subject { build(:address) }

    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:city_part) }
    it { is_expected.to validate_presence_of(:geo_entry_id) }
    it { is_expected.to validate_presence_of(:geo_unit_id) }
    it { is_expected.to validate_presence_of(:coordinate) }
    it { is_expected.to validate_presence_of(:country_code) }
    it { is_expected.to validate_presence_of(:geo_provider) }
  end

  context 'associations' do
    it { should belong_to(:addressable) }
  end

  context 'initialization' do
    subject { Address.new }

    it 'assigns default values' do
      expect(subject.country_code).to eq 'cz'
      expect(subject.geo_provider).to eq 'google_places'
      expect(subject.geo_unit_id).to eq subject.geo_entry_id
      expect(subject.coordinate).to eq Geography::Point.from_coordinates latitude: 0, longitude: 0
    end
  end

  context '.with_calculated_distance' do
    let(:coordinate) { Geography::Point.from_coordinates longitude: 14.4548664, latitude: 50.0941811 }
    let(:coordinate_target) { Geography::Point.from_coordinates longitude: 14.4615350, latitude: 50.0952747 }
    let(:address) { create(:address, coordinate: coordinate, addressable: create(:user)) }

    it 'adds attribute to address model instance' do
      expect(Address.has_attribute?(:distance_meters)).to be false
      expect(Address.with_calculated_distance(address.coordinate).first.has_attribute?(:distance_meters)).to be true
    end

    it 'calculates distance in meters' do
      scope = Address.with_calculated_distance(coordinate_target).where(id: address.id)
      expect(scope.first.distance_meters.to_i).to eq 492
    end
  end

  context '.new_from_string' do
    before do
      allow(Geocoder).to receive(:search).and_return([geocoder_search_mock])
    end

    it 'initializes address with geocoder result' do
      address = Address.new_from_string 'Applifting'
      expect(address.persisted?).to be false

      expect(address.street_number).to eq get_component('street_number', 'long_name')
      expect(address.street).to eq get_component('route', 'long_name')
      expect(address.city).to eq get_component('administrative_area_level_2', 'long_name')
      expect(address.city_part).to eq get_component('neighborhood', 'long_name')
      expect(address.postal_code).to eq get_component('postal_code', 'long_name')
      expect(address.country_code).to eq get_component('country', 'short_name').downcase
      expect(address.geo_entry_id).to eq geocoder_search_mock.data['place_id']
      expect(address.geo_unit_id).to eq geocoder_search_mock.data['place_id']
      expect(address.geo_provider).to eq 'google_places'
    end
  end

  context '#only_address_errors?' do
    subject { build :address, addressable: create(:user) }

    it 'is truthy when address only has some errors' do
      subject.city = nil
      expect(subject.valid?).to be false
      expect(subject.only_address_errors?).to be true
    end

    it 'is false when addressable errors are present' do
      subject.city = nil
      subject.addressable.email = nil
      expect(subject.valid?).to be false
      expect(subject.addressable.valid?).to be false
      expect(subject.only_address_errors?).to be false
    end
  end

  context '#to_s' do
    subject { build :address }

    it 'has expected format' do
      required_values = [subject.street_number, subject.street, subject.city, subject.city_part, subject.postal_code]
      expect(subject.to_s).to eq required_values.uniq.compact.join(', ')
    end
  end

  private

  def get_component(type, property)
    component = geocoder_search_mock.data['address_components'].find { |c| c['types'].include?(type) } || {}
    component[property]
  end
end
