class RequestDecorator < ApplicationDecorator
  decorates_association :address
  delegate_all

  def volunteer_params
    { request_id: object.id }.merge search_params
  end

  def subscriber
    if h.can?(:manage, object)
      subscriber_organisation.present? ? "#{subscriber_organisation} (#{object.subscriber})" : object.subscriber
    else
      object.subscriber_organisation.presence || I18n.t('activerecord.attributes.request.subscriber_hidden')
    end
  end

  def distance_km
    (object.distance_meters / 1000).round(1)
  end

  def distance_km_tag
    return nil unless object.respond_to?(:distance_meters) && object.distance_meters.present?

    h.content_tag :p, format('%{distance} km', distance: distance_km)
  end

  def subscriber_phone_and_messages
    unread_incoming = subscriber_messages.unread.incoming.count
    link_text = unread_incoming.positive? ? 'nepřečetené zprávy' : 'zprávy'

    content = []
    content << object.subscriber_phone
    content << h.link_to(link_text, h.new_admin_subscriber_message_path(request_id: id, subscriber_phone: object.subscriber_phone))
    content.join(' | ').html_safe
  end

  def public_subscriber
    object.subscriber_organisation.presence || I18n.t('activerecord.attributes.request.subscriber_hidden')
  end

  def address_link
    if h.can?(:manage, object) && address
      h.link_to h.content_tag(:span, address.to_s, class: 'action edit'), h.edit_admin_address_path(address)
    else
      address
    end
  end

  private

  def search_params
    return {} unless object.address

    { order: :distance_meters_asc,
      q: { search_nearby: [object.address.coordinate.latitude.to_s, object.address.coordinate.longitude.to_s].join('#') } }
  end
end
