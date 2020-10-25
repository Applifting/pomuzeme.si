module VolunteerHelper
  def login_screen_text(path)
    return :login if path.blank?

    path = VolunteerHelper.normalize_path path
    case path
    when VolunteerHelper.normalize_path(confirm_destruction_of_volunteer_profile_path)
      :delete_profile
    when VolunteerHelper.normalize_path(confirm_interest_path(1))
      :accept_request
    else
      :login
    end
  end

  def self.normalize_path(path)
    path.split('/').reject { |segment| segment.to_i.positive? }.reject(&:blank?).sort
  end
end
