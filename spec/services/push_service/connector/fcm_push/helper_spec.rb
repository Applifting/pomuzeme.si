require 'rails_helper'

describe PushService::Connector::FcmPush::Helper do
  before(:all) { I18n.locale = :cs }

  describe '.event_type' do
    it 'handles event type for request offer messages' do
      message = OpenStruct.new(message: build(:message, :request_offer))
      expect(PushService::Connector::FcmPush::Helper.event_type(message))
        .to eq :REQUEST_CREATED
    end

    it 'handles event type for request update messages' do
      message = OpenStruct.new(message: build(:message, :request_update))
      expect(PushService::Connector::FcmPush::Helper.event_type(message))
        .to eq :REQUEST_UPDATED
    end

    it 'handles event type for all other messages' do
      message = OpenStruct.new(message: build(:message, :other))
      expect(PushService::Connector::FcmPush::Helper.event_type(message))
        .to eq :OTHER
    end
  end

  describe '.notification_title' do
    it 'handles notification title for request offer message' do
      message = OpenStruct.new(message: build(:message, :request_offer))
      expect(PushService::Connector::FcmPush::Helper.notification_title(message))
        .to eq I18n.t('push.notifications.request.new.title')
    end

    it 'handles notification title for request update message' do
      message = OpenStruct.new(message: build(:message, :request_update))
      expect(PushService::Connector::FcmPush::Helper.notification_title(message))
        .to eq I18n.t('push.notifications.request.update.title')
    end

    it 'returns message text for other message types' do
      message = OpenStruct.new(message: build(:message, :other))
      expect(PushService::Connector::FcmPush::Helper.notification_title(message))
        .to eq message.message.text
    end
  end
end
