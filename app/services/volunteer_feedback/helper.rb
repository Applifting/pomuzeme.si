module VolunteerFeedback::Helper
  def decorated_permitted_interpolations
    permitted_interpolations.map { |i| "%{#{i}}" }.join(', ')
  end

  def interpolate_message(message, requested_volunteer)
    format message, fill_interpolations(requested_volunteer)
  end

  def extract_interpolations(text)
    text.scan(/%\{([a-z_]+)\}/).flatten
  end

  def permitted_interpolations
    I18n.t('activerecord.attributes.organisation.volunteer_feedback_interpolations').values
  end

  def permitted_bindings
    I18n.t('activerecord.attributes.organisation.volunteer_feedback_interpolations')
  end

  def fill_interpolations(requested_volunteer)
    raw_hash = permitted_bindings.map do |metod, interpolation|
      [interpolation, requested_volunteer.send(metod)]
    end.to_h

    raw_hash.transform_keys { |key| key.to_sym }
  end
end
