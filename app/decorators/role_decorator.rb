class RoleDecorator < ApplicationDecorator

  delegate_all
  decorates :role

  def actions
    [button_delete].compact.join(' | ').html_safe
  end

  def button_delete
    h.link_to 'smazat', '', method: :get, class: 'confirm', 'data-warning': 'Smazat roli?'
  end
end