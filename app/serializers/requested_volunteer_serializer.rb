class RequestedVolunteerSerializer < ActiveModel::Serializer

  attributes :id,
             :state,
             :requested_volunteer_state,
             :short_description,
             :city,
             :city_part,
             :organisation_id,
             :fullfillment_date,
             :created_at,
             :updated_at,
             :closed_state, # attributes below are shown only if volunteer interacted with request
             :closed_note,
             :coordinator,
             :subscriber, # attributes below are considered as sensitive
             :subscriber_phone,
             :address

  def id
    object.request.id
  end

  def requested_volunteer_state
    object.state
  end

  def state
    object.request.state
  end

  def short_description
    object.request.text
  end

  def city
    object.request.address&.city
  end

  def city_part
    object.request.address&.city
  end

  def address
    object.request.address
  end

  def organisation_id
    object.request.organisation_id
  end

  def fullfillment_date
    object.request.fullfillment_date
  end

  def coordinator
    object.request.coordinator.to_s
  end

  def closed_state
    object.request.closed_state
  end

  def closed_note
    object.request.closed_note
  end

  def subscriber
    object.request.subscriber
  end

  def subscriber_phone
    object.request.subscriber_phone
  end



  private

  def show_extended?
    @show_extended ||= !object.state.in?(%w[pending_notification notified].freeze)
  end
end

# long_description, address, name, surname, phone (pokud coordinator neudelil pristup, poslat u citlivych udaju null),
# u tech, kde se ceka moje reakce (request_volunteer_state == notified): id, short_description, city+cityPart, fullfillment_date, org_id, state , request_volunteer_state, created_at, updated_at, all_details_granted (bool, ma dobrovolnik pristup ke vsem fieldum, vcetne citivych?)