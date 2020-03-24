require 'rails_helper'

describe Geography::Point do
  describe '#from_coordinates' do
    it 'creates geo point with passed values' do
      latitude = 50.0941811
      longitude = 14.4548664

      point = Geography::Point.from_coordinates longitude: longitude, latitude: latitude
      expect(point.latitude).to eq latitude
      expect(point.longitude).to eq longitude
    end
  end

  describe '#from_s_jtsk' do
    # verify at http://martin.hinner.info/geo/
    it 'converts S-JTSK coordinate into WGS-84' do
      s_jtsk_x = -1061338.289999999
      s_jtsk_y = -648360.4600000009

      point = Geography::Point.from_s_jtsk y: s_jtsk_x, x: s_jtsk_y
      expect(point.latitude).to eq 50.0322834658438
      expect(point.longitude).to eq 15.7622390467497
    end
  end
end
