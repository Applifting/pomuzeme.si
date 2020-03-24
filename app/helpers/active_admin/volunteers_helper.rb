module ActiveAdmin
  module VolunteersHelper
    def scoped_request
      return @scoped_request if defined? @scoped_request

      @scoped_request = Request.find_by id: params[:request_id]
    end

    def referer_request
      referer_params = Rack::Utils.parse_nested_query(URI.parse(request.referer).query)
      Request.find referer_params['request_id']
    end
  end
end
