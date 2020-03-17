class VolunteersController < ApplicationController
  def register
    volunteer = Volunteer.new(volunteer_params).with_existing_record
    address = Address.new(address_params.merge(addressable: volunteer))

    if volunteer.valid? && address.valid? && agreements_granted?(volunteer) && save_and_send_code(volunteer)
      render 'volunteer/register_success'
    else
      render 'volunteer/register_error', locals: {volunteer: volunteer, address: address}
    end
  end

  def confirm
    volunteer = Volunteer.find_by id: session[:volunteer]
    return render 'volunteer/confirm_error', locals: {error: I18n.t('activerecord.errors.messages.volunteer_not_found')} if volunteer.nil?

    volunteer.confirm_with(confirm_params[:confirmation_code])
    return render 'volunteer/confirm_error', locals: {volunteer: volunteer} if volunteer.errors.any?

    session[:volunteer] = nil
    render 'volunteer/confirm_success'
  end

  def resend
    volunteer = Volunteer.find_by id: session[:volunteer]
    return render 'volunteer/confirm_error', locals: {error: I18n.t('activerecord.errors.messages.volunteer_not_found')} if volunteer.nil?

    resend_code volunteer
    return render 'volunteer/confirm_error', locals: {volunteer: volunteer} if volunteer.errors.any?

    render 'volunteer/confirm_resended'
  end

  private

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :phone, :email)
  end

  def address_params
    params.require(:volunteer).permit(
        :street, :city, :street_number, :city_part, :geo_entry_id, :geo_unit_id, :geo_coord_x, :geo_coord_y
    )
  end

  def confirm_params
    params.permit :confirmation_code
  end

  def agreements_params
    params.require(:volunteer).permit(:terms_of_service, :age_confirmed)
  end

  def save_and_send_code(volunteer)
    with_captured_exception volunteer do |safe_volunteer|
      safe_volunteer.save!
      safe_volunteer.obtain_confirmation_code
      session[:volunteer] = safe_volunteer.id
      true
    end
  end

  def resend_code(volunteer)
    with_captured_exception volunteer, &:obtain_confirmation_code
  end

  def with_captured_exception(volunteer)
    ActiveRecord::Base.transaction do
      yield volunteer
    rescue StandardError
      volunteer.errors.add(:base, :sms_not_working)
      raise ActiveRecord::Rollback
    end
  end

  def agreements_granted?(volunteer)
    volunteer.errors.add(:base, :terms_of_service_required) if agreements_params[:terms_of_service] != '1'
    volunteer.errors.add(:base, :age_confirmed_required) if agreements_params[:age_confirmed] != '1'

    volunteer.errors.empty?
  end
end
