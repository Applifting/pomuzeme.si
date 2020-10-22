class VolunteersController < ApplicationController
  before_action :partner_signup_group

  def register
    volunteer = Volunteer.new(volunteer_params).with_existing_record
    address = volunteer.addresses.build address_with_coordinate

    if resolve_recaptcha(volunteer) && volunteer.valid? && agreements_granted?(volunteer) && save_and_send_code(volunteer)
      bind_volunteer_with_organisation_group(volunteer) if @partner_signup_group
      render 'volunteer/register_success'
    else
      Rails.logger.error address.errors.messages
      render 'volunteer/register_error', locals: { volunteer: volunteer, address: address }
    end
  end

  def confirm
    volunteer = Volunteer.find_by id: session[:volunteer_id]
    return render 'volunteer/confirm_error', locals: { error: I18n.t('activerecord.errors.messages.volunteer_not_found') } if volunteer.nil?

    volunteer.confirm_with(confirm_params[:confirmation_code])
    return render 'volunteer/confirm_error', locals: { volunteer: volunteer } if volunteer.errors.any?

    # TODO: We should not show any error to user if welcome SMS was not sent,
    # but we should be able to identify SMS that were not sent.
    partner_group = volunteer.groups.take
    SmsService::Manager.send_welcome_msg(volunteer.phone, partner_group)

    render 'volunteer/confirm_success'
  end

  def resend
    volunteer = Volunteer.find_by id: session[:volunteer_id]
    return render 'volunteer/confirm_error', locals: { error: I18n.t('activerecord.errors.messages.volunteer_not_found') } if volunteer.nil?

    resend_code volunteer
    return render 'volunteer/confirm_error', locals: { volunteer: volunteer } if volunteer.errors.any?

    render 'volunteer/confirm_resended'
  end

  private

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :phone, :email, :description)
  end

  def address_params
    params.require(:volunteer).permit(
      :street, :city, :street_number, :city_part, :postal_code, :country_code, :geo_entry_id, :geo_unit_id, :geo_coord_x, :geo_coord_y
    )
  end

  def address_with_coordinate
    coordinate = Geography::Point.from_coordinates latitude: address_params[:geo_coord_y].to_d,
                                                   longitude: address_params[:geo_coord_x].to_d
    address_params.except(:geo_coord_x, :geo_coord_y).merge(coordinate: coordinate,
                                                            geo_provider: 'google_places',
                                                            default: true)
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
      session[:volunteer_id] = safe_volunteer.id
      true
    end
  end

  def resend_code(volunteer)
    with_captured_exception volunteer, &:obtain_confirmation_code
  end

  def with_captured_exception(volunteer)
    ActiveRecord::Base.transaction do
      yield volunteer
    rescue StandardError => e
      Raven.capture_exception e

      # TODO: sms_not_working is misleading and difficult to debug. There can be model validation issues raising errors.
      volunteer.errors.add(:base, :sms_not_working)
      raise ActiveRecord::Rollback
    end
  end

  def bind_volunteer_with_organisation_group(volunteer)
    @partner_signup_group.add_group_volunteer(volunteer)
  end

  def agreements_granted?(volunteer)
    volunteer.errors.add(:base, :terms_of_service_required) if agreements_params[:terms_of_service] != '1'
    volunteer.errors.add(:base, :age_confirmed_required) if agreements_params[:age_confirmed] != '1'

    volunteer.errors.empty?
  end

  def partner_signup_group
    @partner_signup_group = Group.find(session[:group_id]) if session[:group_id]
  end

  def resolve_recaptcha(_volunteer)
    # TEMPORARY DISABLED
    # score_threshold = ENV['RECAPTCHA_THRESHOLD']&.to_f
    # if score_threshold.present?
    # recaptcha = verify_recaptcha(action: 'login', minimum_score: score_threshold)
    #  volunteer.errors[:recaptcha] << 'je neplatné' unless recaptcha
    #  recaptcha
    # else
    #  true
    # end
    true
  end
end
