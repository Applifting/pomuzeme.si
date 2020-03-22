class ApplicationController < ActionController::Base
  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  rescue_from PG::ForeignKeyViolation do |error|
    Raven.capture_exception error
    redirect_to request.referrer, alert: 'Tato položka se používá. Pokud jí potřebujete smazat, napište na info@pomuzeme.si'
  end

  rescue_from CanCan::AccessDenied do |error|
    Raven.capture_exception error
    redirect = request.referrer || '/admin'
    redirect_to redirect, alert: I18n.t('errors.authorisation.resource', action: error.action, subject: error.subject)
  end
end
