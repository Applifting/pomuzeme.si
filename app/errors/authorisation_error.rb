class AuthorisationError < StandardError
  attr_accessor :action, :subject

  def initialize(action, model)
    @action  = action
    @subject = model
  end

  def message
    :not_authorised_for_resource
  end
end
