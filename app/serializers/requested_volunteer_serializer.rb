class RequestedVolunteerSerializer < ActiveModel::Serializer

  attributes :id,
             :state,
             :requested_volunteer_state,
             :title,
             :short_description,
             :city,
             :city_part,
             :organisation_id,
             :fullfillment_date,
             :required_volunteer_count,
             :accepted_volunteer_count,
             :created_at,
             :updated_at,
             :closed_state, # attributes below are shown only if volunteer interacted with request
             :closed_note,
             :coordinator,
             :subscriber, # attributes below are considered as sensitive
             :subscriber_phone,
             :address,
             :long_description,
             :all_details_granted # indicates if user can see all fields including sensitive

  def id
    object.request.id
  end

  def requested_volunteer_state
    object.state
  end

  def state
    object.request.state
  end

  def title
    object.request.text[0..29]
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

  def required_volunteer_count
    object.request.required_volunteer_count
  end

  def accepted_volunteer_count
    object.request.required_volunteer_count
  end

  def organisation_id
    object.request.organisation_id
  end

  def created_at
    object.request.created_at
  end

  def updated_at
    object.request.created_at
  end

  def fullfillment_date
    object.request.fullfillment_date
  end

  def coordinator
    ActiveModelSerializers::SerializableResource.new object.request.coordinator
  end

  def closed_state
    return unless show_extended?

    object.request.closed_state
  end

  def closed_note
    return unless show_extended?

    object.request.closed_note
  end

  def address
    return unless show_extended? && object.visible_sensitive

    ActiveModelSerializers::SerializableResource.new object.request.address
  end

  def subscriber
    return unless show_extended? && object.visible_sensitive

    object.request.subscriber
  end

  def subscriber_phone
    return unless show_extended? && object.visible_sensitive

    object.request.subscriber_phone
  end

  def long_description
    return unless show_extended? && object.visible_sensitive

    object.request.long_text
  end

  def all_details_granted
    object.visible_sensitive
  end

  private

  def show_extended?
    @show_extended ||= !object.state.in?(%w[pending_notification notified].freeze)
  end
end