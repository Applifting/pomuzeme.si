class Message < ApplicationRecord
  VOLUNTEER_MESSAGES_WITH_REQUEST_SQL = 'volunteer_id = %{volunteer_id} AND (request_id IS NULL OR request_id = %{request_id})'.freeze

  # Callbacks
  after_create  :update_unread_messages_counter_cache
  after_destroy :update_unread_messages_counter_cache
  after_update  :update_unread_messages_counter_cache

  # Associations
  belongs_to :volunteer, optional: true
  belongs_to :creator, optional: true, class_name: 'User', foreign_key: :created_by_id
  belongs_to :request, optional: true

  # Attributes
  enum state: { pending: 1, sent: 2, received: 3 }
  enum direction: { outgoing: 1, incoming: 2 }
  enum channel: { sms: 1, push: 2 }
  enum message_type: { other: 1, request_offer: 2, request_update: 3, subscriber: 4 }, _prefix: true

  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'

  # Validations
  validates_presence_of :text

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :with_request_and_volunteer, ->(request_id:, volunteer_id:) do
    where(format(VOLUNTEER_MESSAGES_WITH_REQUEST_SQL, request_id: request_id, volunteer_id: volunteer_id))
  end

  def mark_as_read
    update read_at: Time.zone.now if read_at.nil?
  end

  def read?
    read_at.present?
  end

  def self.mark_read(request_id:, volunteer_id:)
    Message.incoming.unread.with_request_and_volunteer(request_id: request_id, volunteer_id: volunteer_id).each do |message|
      message.update(read_at: Time.zone.now)
    end
  end

  def self.update_unread_messages_counter_cache(volunteer_id:, request_id:)
    # Incoming SMS cannot be matched with specific request, hence optional request_id
    # when such message is received, all matching requested volunteers' cache is updated
    # so that all requests with this volunteer is flagged as unread
    requested_volunteers = RequestedVolunteer.with_optional_request_id(volunteer_id, request_id)

    requested_volunteers.each do |requested_volunteer|
      requested_volunteer.update(unread_incoming_messages_count: requested_volunteer.unread_incoming_messages.count)
    end
  end

  private

  def update_unread_messages_counter_cache
    Message.update_unread_messages_counter_cache(volunteer_id: volunteer_id, request_id: request_id)
  end
end
