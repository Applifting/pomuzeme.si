class RoleDecorator < ApplicationDecorator

  delegate_all
  decorates :role

end