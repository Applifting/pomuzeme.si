class Message < ApplicationRecord
  include MessageStateManipulation

  MESSAGES_FOR_REQUEST_SQL = 'volunteer_id = %{volunteer_id} AND (request_id IS NULL OR request_id = %{request_id})'.freeze

  # Associations
  belongs_to :volunteer, optional: true
  belongs_to :creator, optional: true, class_name: 'User', foreign_key: :created_by_id
  belongs_to :request, optional: true

  # Attributes
  enum state: { pending: 1, sent: 2, received: 3 }
  enum direction: { outgoing: 1, incoming: 2 }
  enum channel: { sms: 1 }
  enum message_type: { other: 1, request_offer: 2 }, _prefix: true

  # Validations
  validates_presence_of :text

  # Hooks
  after_commit :send_outgoing_message, on: :create, if: :outgoing? # perform job outside transaction
  after_commit :process_incoming_message, on: :create, if: :incoming? # perform job outside transaction
  after_commit :process_state_changed, on: :update, if: :saved_change_to_state?

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :incoming, -> { where(direction: 2) }
  scope :for_request, ->(request_id, volunteer_id) { where(format(MESSAGES_FOR_REQUEST_SQL, request_id: request_id, volunteer_id: volunteer_id)) }

  def mark_as_read
    update read_at: Time.zone.now
  end

  private

  def send_outgoing_message
    MessageSenderJob.perform_later id
  end

  def process_incoming_message
    MessageReceivedProcessorJob.perform_later self
  end
end
