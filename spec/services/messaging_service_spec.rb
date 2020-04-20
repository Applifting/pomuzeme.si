require 'rails_helper'

describe MessagingService do
  before(:all) { I18n.locale = :cs }

  let(:message) { create :message }
  let(:outgoing_message) { MessagingService::OutgoingMessage.new message }

  describe '.create_message' do
    it 'creates Message with given args' do
      create_args = {text: 'foobar'}
      expect(Message).to receive(:create!).with(create_args).and_return(create :message)
      MessagingService.create_message create_args
    end

    it 'delivers message via background job' do
      ActiveJob::Base.queue_adapter = :test
      expect { MessagingService.create_message build(:message).attributes }
        .to have_enqueued_job(Messages::SenderJob)
    end
  end

  describe '.callback' do
    it 'delegates callback calling to common module' do
      expect(MessagingService::Callbacks).to receive(:message_sent)
                                                 .with([])
      MessagingService.callback :message_sent, []
    end
  end
end
