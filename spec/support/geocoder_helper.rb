module GeocoderHelper
  def mock_geocoder_search
    allow(Geocoder).to receive(:search).with(any_args).and_return(geocoder_search_mock)
  end

  def geocoder_search_mock
    [OpenStruct.new(data: { 'address_components' =>
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
                            'types' => %w[establishment point_of_interest] })]
  end
end