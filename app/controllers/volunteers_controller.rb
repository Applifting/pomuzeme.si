class VolunteersController < ApplicationController
  def register
    volunteer = Volunteer.new(volunteer_params).with_existing_record
    if volunteer.valid?
      render 'volunteer/register_success', locals: { volunteer: volunteer }
    else
      render 'volunteer/register_error', locals: { volunteer: volunteer }
    end
  end

  def confirm
    # Load current volunteer from session and validate code
  end

  private

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :street, :city, :zipcode, :phone, :email)
  end

  def confirm_params
    params.permit :confirmation_code
  end
end
