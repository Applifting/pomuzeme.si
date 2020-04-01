class Message < ApplicationRecord
  MESSAGES_FOR_REQUEST_SQL = 'volunteer_id = %{volunteer_id} AND (request_id IS NULL OR request_id = %{request_id})'.freeze

  # Associations
  belongs_to :volunteer, optional: true
  belongs_to :creator, optional: true, class_name: 'User', foreign_key: :created_by_id
  belongs_to :request, optional: true

  # Attributes
  enum state: { pending: 1, sent: 2, received: 3 }
  enum direction: { outgoing: 1, incoming: 2 }
  enum channel: { sms: 1 }

  # Validations
  validates_presence_of :text

  # Hooks
  after_create :send_outgoing_message

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :incoming, -> { where(direction: 2) }
  scope :for_request, ->(request_id, volunteer_id) { where(format(MESSAGES_FOR_REQUEST_SQL, request_id: request_id, volunteer_id: volunteer_id)) }

  def mark_as_read
    update read_at: Time.zone.now
  end

  private

  def send_outgoing_message
    return if direction.to_sym == :incoming

    MessagingService.send(self)
  end
end
