# frozen_string_literal: true

module Authorizable
  include ActiveSupport::Concern

  def admin?
    has_any_role? :super_admin
  end

  def coordinator?
    has_any_role? :coordinator
  end
end
