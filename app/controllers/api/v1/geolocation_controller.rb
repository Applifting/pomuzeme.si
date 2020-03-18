class Api::V1::GeolocationController < ApplicationController
  DEFAULT_RESPONSE = [
    {
      'Fid' => 35350402,
      'okres_kod' => 3100,
      'okres_nazev' => 'Hlavní město Praha',
      'obec_kod' => 554782,
      'obec_nazev' => 'Praha',
      'cast_obce_kod' => 400637,
      'cast_obce_nazev' => 'Karlín',
      'ulice_kod' => 471011,
      'ulice_nazev' => 'Šaldova',
      'adresa_kod' => 22353615,
      'cislo' => 'č.p. 476/9'
    }
  ].freeze

  def fulltext
    url = ENV['GEO_URL']

    if Rails.env.development? && url.blank?
      render json: DEFAULT_RESPONSE, status: 200
      return
    end

    response = HTTParty.post(url, { body: params.permit('Input') })
    render json: response.parsed_response, status: response.code
  end
end
