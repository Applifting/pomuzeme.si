class Api::V1::GeolocationController < ApplicationController

  def fulltext
    url = ENV['GEO_URL']
    response = HTTParty.post(url, {body: params.permit('Input')})
    render json: response.parsed_response, status: response.code
  end

end