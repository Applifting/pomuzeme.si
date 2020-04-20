module MessagingServiceHelper

  def message_response(message_id: nil, number: nil, text: nil, timestamp: nil)
    OpenStruct.new(channel_msg_id: message_id || 42,
                   from_number: number || '123456789',
                   text: text || 'response text',
                   delivery_receipt_timestamp: timestamp || DateTime.now)
  end
end