module ApiHelper
  def authorized_post(volunteer:, path:, params: nil)
    post path, params: params, headers: { 'HTTP_AUTHORIZATION' => Api::JsonWebToken.encode(volunteer_id: volunteer.id) }
  end
end