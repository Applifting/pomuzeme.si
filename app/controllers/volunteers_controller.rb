class VolunteersController < ApplicationController
  def register
    volunteer = Volunteer.new volunteer_params
    # TODO: validate, save and render JS response
  end

  def confirm
  end

  private

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :street, :city, :zipcode, :phone, :email)
  end

  def confirm_params
    params.permit :confirmation_code
  end
end
