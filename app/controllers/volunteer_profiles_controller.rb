class VolunteerProfilesController < PublicController
  skip_before_action :authorize_current_volunteer, only: [:destroyed]

  def show
    @volunteer = Volunteer.includes(volunteer_interests: :interest, volunteer_skills: :skill)
                          .where(id: @current_volunteer.id)
                          .first
  end

  def update
    @volunteer = Volunteer.includes(volunteer_interests: :interest, volunteer_skills: :skill)
                          .where(id: @current_volunteer.id)
                          .first

    ActiveRecord::Base.transaction do
      @volunteer.update volunteer_params
      @volunteer.address.update address_with_coordinate

      update_interests
      update_skills
    end

    flash[:success] = 'Profil uložen.'
    redirect_to volunteer_profile_path
  end

  def confirm_destroy
  end

  def destroy
    Volunteer.find(@current_volunteer.id).destroy

    redirect_to logout_path(redirect_to: profile_destroyed_path)
  end

  def destroyed
  end


  private

  def update_interests
    return if interests_params.keys == @volunteer.volunteer_interests.map(&:interest).map(&:code)

    @volunteer.volunteer_interests.destroy_all
    interests = Interest.where(code: interests_params[:interests]&.keys)
    @volunteer.interests << interests
  end

  def update_skills
    return if skills_params.keys == @volunteer.volunteer_skills.map(&:skill).map(&:code)

    @volunteer.volunteer_skills.destroy_all
    skills = Skill.where(code: skills_params[:skills]&.keys)
    @volunteer.skills << skills
  end


  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :phone, :email, :description, :other_skills, :other_interests)
  end

  def address_params
    params.require(:volunteer).permit(
      :street, :city, :street_number, :city_part, :postal_code, :country_code, :geo_entry_id, :geo_unit_id, :geo_coord_x, :geo_coord_y
    )
  end

  def skills_params
    params.permit(skills: Skill.all.pluck(:code))
  end

  def interests_params
    params.permit(interests: Interest.all.pluck(:code))
  end

  def address_with_coordinate
    coordinate = Geography::Point.from_coordinates latitude: address_params[:geo_coord_y].to_d,
                                                   longitude: address_params[:geo_coord_x].to_d
    address_params.except(:geo_coord_x, :geo_coord_y).merge(coordinate: coordinate,
                                                            geo_provider: 'google_places',
                                                            default: true)
  end
end