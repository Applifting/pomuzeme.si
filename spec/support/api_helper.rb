module ApiHelper
  def authorized_post(volunteer:, path:, params: nil)
    post path, params: params, headers: { 'HTTP_AUTHORIZATION' => Api::JsonWebToken.encode(volunteer_id: volunteer.id) }
  end

  def authorized_get(volunteer:, path:, params: nil)
    get path, params: params, headers: { 'HTTP_AUTHORIZATION' => Api::JsonWebToken.encode(volunteer_id: volunteer.id) }
  end

  def authorized_put(volunteer:, path:, params: nil)
    put path, params: params, headers: { 'HTTP_AUTHORIZATION' => Api::JsonWebToken.encode(volunteer_id: volunteer.id) }
  end

  def authorized_delete(volunteer:, path:, params: nil)
    delete path, params: params, headers: { 'HTTP_AUTHORIZATION' => Api::JsonWebToken.encode(volunteer_id: volunteer.id) }
  end
end