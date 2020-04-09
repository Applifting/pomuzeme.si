# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'validations' do
    subject { build(:address) }

    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:city_part) }
    it { is_expected.to validate_presence_of(:geo_entry_id) }
    it { is_expected.to validate_presence_of(:geo_unit_id) }
    it { is_expected.to validate_presence_of(:coordinate) }
    it { is_expected.to validate_presence_of(:country_code) }
    it { is_expected.to validate_presence_of(:geo_provider) }
  end

  describe 'associations' do
    it { should belong_to(:addressable) }
  end

  describe 'initialization' do
    subject { Address.new }

    it 'assigns default values' do
      expect(subject.country_code).to eq 'cz'
      expect(subject.geo_provider).to eq 'google_places'
      expect(subject.geo_unit_id).to eq subject.geo_entry_id
      expect(subject.coordinate).to eq Geography::Point.from_coordinates latitude: 0, longitude: 0
    end
  end

  describe '.with_calculated_distance' do
    let(:coordinate) { Geography::Point.from_coordinates longitude: 14.4548664, latitude: 50.0941811 }
    let(:coordinate_target) { Geography::Point.from_coordinates longitude: 14.4615350, latitude: 50.0952747 }
    let(:address) { create(:address, coordinate: coordinate, addressable: create(:user)) }

    it 'adds attribute to address model instance' do
      expect(Address.has_attribute?(:distance_meters)).to be_falsey
      expect(Address.with_calculated_distance(address.coordinate).first.has_attribute?(:distance_meters)).to be_truthy
    end

    it 'calculates distance in meters' do
      scope = Address.with_calculated_distance(coordinate_target).where(id: address.id)
      expect(scope.first.distance_meters.to_i).to eq 492
    end
  end

  describe '.new_from_string' do
    before do
      allow(Geocoder).to receive(:search).and_return([geocoder_search_mock])
    end

    it 'initializes address with geocoder result' do
      address = Address.new_from_string 'Applifting'
      expect(address.persisted?).to be_falsey

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

  describe '#only_address_errors?' do
    subject { build :address, addressable: create(:user) }

    it 'is truthy when address only has some errors' do
      subject.city = nil
      expect(subject.valid?).to be_falsey
      expect(subject.only_address_errors?).to be_truthy
    end

    it 'is false when addressable errors are present' do
      subject.city = nil
      subject.addressable.email = nil
      expect(subject.valid?).to be_falsey
      expect(subject.addressable.valid?).to be_falsey
      expect(subject.only_address_errors?).to be_falsey
    end
  end

  describe '#to_s' do
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

  def geocoder_search_mock
    OpenStruct.new(data: { 'address_components' =>
                              [{ 'long_name' => '476/9',
                                 'short_name' => '476/9',
                                 'types' => ['street_number'] },
                               { 'long_name' => 'Šaldova', 'short_name' => 'Šaldova', 'types' => ['route'] },
                               { 'long_name' => 'Karlín',
                                 'short_name' => 'Karlín',
                                 'types' => %w[neighborhood political] },
                               { 'long_name' => 'Hlavní město Praha',
                                 'short_name' => 'Hlavní město Praha',
                                 'types' => %w[administrative_area_level_2 political] },
                               { 'long_name' => 'Hlavní město Praha',
                                 'short_name' => 'Hlavní město Praha',
                                 'types' => %w[administrative_area_level_1 political] },
                               { 'long_name' => 'Česko',
                                 'short_name' => 'CZ',
                                 'types' => %w[country political] },
                               { 'long_name' => '186 00',
                                 'short_name' => '186 00',
                                 'types' => ['postal_code'] }],
                           'formatted_address' => 'Šaldova 476/9, 186 00 Praha-Karlín, Česko',
                           'geometry' =>
                              { 'location' => { 'lat' => 50.09415, 'lng' => 14.4548674 },
                                'location_type' => 'ROOFTOP',
                                'viewport' =>
                                   { 'northeast' => { 'lat' => 50.0954989802915, 'lng' => 14.4562163802915 },
                                     'southwest' => { 'lat' => 50.0928010197085, 'lng' => 14.4535184197085 } } },
                           'place_id' => 'ChIJFxySP6_sC0cR-41HsixfmFw',
                           'plus_code' =>
                              { 'compound_code' => '3FV3+MW Karlín, Praha 8, Česko',
                                'global_code' => '9F2P3FV3+MW' },
                           'types' => %w[establishment point_of_interest] })
  end
end
