class ApplicationController < ActionController::Base
  before_action :set_raven_context

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  rescue_from PG::ForeignKeyViolation do |error|
    Raven.capture_exception error
    redirect_to request.referrer, alert: 'Tato položka se používá. Pokud jí potřebujete smazat, napište na info@pomuzeme.si'
  end

  rescue_from AuthorisationError do |error|
    Raven.capture_exception error
    redirect = request.referrer || '/admin'
    redirect_to redirect, alert: I18n.t("errors.authorisation.#{error.message}",
                                        action: error.action,
                                        subject: error.subject)
  end

  rescue_from StandardError do |error|
    Raven.capture_exception error
    raise error
  end

  def set_raven_context
    Raven.user_context(id: current_user.id) if current_user
  end
end
