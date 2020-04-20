class Api::V1::Volunteer::AddressesController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: :foreign_address_response

  def index
    json_response current_volunteer.addresses
  end

  def show
    json_response current_volunteer.addresses.find(permitted_params[:id])
  end

  def create
    address = current_volunteer.addresses.new ::Address.attributes_for_geo_result(geo_result).merge(permitted_params.slice(:default))
    validate! address
    address.save!
    json_response address, status: :created
  end

  def update
    address = current_volunteer.addresses.find(permitted_params[:id])
    address.assign_attributes ::Address.attributes_for_geo_result(geo_result).merge(permitted_params.slice(:default))
    validate! address
    address.save!
    json_response address, status: :accepted
  end

  def destroy
    current_volunteer.addresses.find(permitted_params[:id]).destroy!

    head :ok
  end


  private

  def geo_result
    Geocoder.search(permitted_params[:place_id], lookup: :google_places_details).first.tap do |result|
      raise Api::Address::UnknownLocationError if result.nil?
    end
  end

  def permitted_params
    params.permit :id, :place_id, :default
  end

  def foreign_address_response
    error_response ApiErrors[:UNAUTHORIZED_RESOURCE], status: :unauthorized
  end

  def validate!(address)
    return if address.valid?

    raise Api::InvalidArgumentError, address.errors.full_messages.join("\n")
  end
end
