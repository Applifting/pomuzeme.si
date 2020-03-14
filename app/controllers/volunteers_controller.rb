class VolunteersController < ApplicationController
  def register
    volunteer = Volunteer.new(volunteer_params).with_existing_record
    if volunteer.valid? && agreements_granted?(volunteer) && save_and_send_code(volunteer)
      render 'volunteer/register_success'
    else
      render 'volunteer/register_error', locals: { volunteer: volunteer }
    end
  end

  def confirm
    volunteer = Volunteer.find_by id: session[:volunteer]
    return render 'volunteer/confirm_error', locals: { error: I18n.t('activerecord.errors.messages.volunteer_not_found') } if volunteer.nil?

    volunteer.confirm_with(confirm_params[:confirmation_code])
    return render 'volunteer/confirm_error', locals: { volunteer: volunteer } if volunteer.errors.any?

    session[:volunteer] = nil
    render 'volunteer/confirm_success'
  end

  private

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :street, :city, :zipcode, :phone, :email)
  end

  def confirm_params
    params.permit :confirmation_code
  end

  def agreements_params
    params.require(:volunteer).permit(:terms_of_service, :age_confirmed)
  end

  def save_and_send_code(volunteer)
    ActiveRecord::Base.transaction do
      volunteer.save!
      volunteer.obtain_confirmation_code
      session[:volunteer] = volunteer.id
      true
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
