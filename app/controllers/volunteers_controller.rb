class VolunteersController < ApplicationController
  def register
    volunteer = Volunteer.new(volunteer_params).with_existing_record
    if volunteer.valid?
      save_and_send_code volunteer
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

    render 'volunteer/confirm_success'
  end

  private

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :street, :city, :zipcode, :phone, :email)
  end

  def confirm_params
    params.permit :confirmation_code
  end

  def save_and_send_code(volunteer)
    volunteer.save!
    volunteer.obtain_confirmation_code
    session[:volunteer] = volunteer.id
  end
end
