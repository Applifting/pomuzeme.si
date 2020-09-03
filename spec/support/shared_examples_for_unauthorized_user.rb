RSpec.shared_examples "unauthorized user" do
  it 'returns not found error' do
    send http_method.to_sym, url_path
    expect(response.body).to include_json(error_key: 'UNAUTHORIZED_RESOURCE')
    expect(response.body).to include_json(message: nil)
  end

  it 'returns status code 401' do
    send http_method.to_sym, url_path
    expect(response).to have_http_status(401)
  end
end
