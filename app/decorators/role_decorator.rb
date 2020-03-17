class RoleDecorator < ApplicationDecorator

  delegate_all
  decorates :role

  def actions(user)
    [button_delete].compact.join(' | ').html_safe
  end

  def button_delete
    h.link_to 'smazat', destroy_role_admin_user_path(), method: :post, class: 'confirm', 'data-warning': 'Smazat roli?'
  end
end