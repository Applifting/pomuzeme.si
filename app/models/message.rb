class Message < ApplicationRecord
  # Associations
  belongs_to :volunteer, optional: true
  belongs_to :creator, class_name: 'User', foreign_key: :created_by_id
  belongs_to :request, optional: true

  # Attributes
  enum state: { pending: 1, sent: 2, received: 3 }
  enum direction: { outgoing: 1, incoming: 2 }
  enum channel: { sms: 1 }

  # Validations
  validates_presence_of :text

  # Hooks
  after_create :send_outgoing_message

  private

  def send_outgoing_message
    return if direction == :incoming

    MessagingService.send(self)
  end
end