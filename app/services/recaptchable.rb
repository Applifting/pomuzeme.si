module Recaptchable
  def resolve_recaptcha(model, threshold = nil)
    score_threshold = threshold&.to_f

    if score_threshold.present?
      recaptcha = verify_recaptcha(action: 'login', minimum_score: score_threshold)
      model.errors[:recaptcha] << 'si myslí, že jste robot. Zkusíte to znovu?' unless recaptcha
      Raven.capture_exception AuthorisationError.new(:recaptcha, model) unless recaptcha
      recaptcha
    else
      true
    end
  end
end