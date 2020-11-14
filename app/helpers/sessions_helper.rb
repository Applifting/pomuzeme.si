module SessionsHelper
  def login_screen_text(path)
    return :login if path.blank?

    path = SessionsHelper.normalize_path path
    case path
    when SessionsHelper.normalize_path(confirm_destruction_of_volunteer_profile_path)
      :delete_profile
    when SessionsHelper.normalize_path(accept_request_path)
      :accept_request
    else
      :login
    end
  end

  def self.normalize_path(path)
    without_params = path.split('?').first
    new_path       = without_params.split('/').reject { |segment| segment.to_i.positive? }
                                   .reject(&:blank?).sort
    new_path
  end
end
