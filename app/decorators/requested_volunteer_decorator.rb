class RequestedVolunteerDecorator < ApplicationDecorator
  delegate_all

  def actions
    [button_edit].compact.join(' | ').html_safe
  end

  def button_edit
    h.link_to 'upravit', h.edit_admin_organisation_request_requested_volunteer_path(request_id, id)
  end

  def button_delete
    h.link_to 'smazat', h.admin_organisation_request_requested_volunteer_path(request_id, id), method: :delete, 'data-confirm': 'Smazat dobrovolnika?'
  end
end
