class SlackBot
  def self.send_new_request_notification(request, path)
    channel = ENV.fetch 'SLACK_NEW_REQUEST_CHANNEL', 'test-notifikaci'

    text = format ":new: *<https://pomuzeme.si%{path}|Nová poptávka>* od %{subscriber}.", path: path, subscriber: request.subscriber

    SlackBot.send_message text, channel
  end

  def self.send_message(text, channel)
    return unless ENV['SLACK_API_TOKEN'].present?

    ::SLACK.chat_postMessage(channel: channel, text: text)
  rescue => e
    Raven.capture_exception e
  end
end
