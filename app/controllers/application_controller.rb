class ApplicationController < ActionController::Base
  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end

  rescue_from PG::ForeignKeyViolation do |_error|
    # Raven.capture_exception error
    redirect_to request.referrer, alert: 'Tato položka se používá. Pokud jí potřebujete smazat, napište na info@pomuzeme.si'
  end
end
