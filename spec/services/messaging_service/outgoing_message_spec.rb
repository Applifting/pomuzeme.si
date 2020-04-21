require 'rails_helper'

describe MessagingService::OutgoingMessage do
  before(:all) { I18n.locale = :cs }
  let(:message) { create :message, text: 'foobar' }
  let(:outgoing_message) { MessagingService::OutgoingMessage.new message }

  describe '#text' do
    it 'contains creator signature if present' do
      allow(outgoing_message).to receive(:message_has_creator?).and_return(true)
      allow(outgoing_message).to receive(:creator_signature).and_return('baz')
      expect(outgoing_message.text).to eq 'foobar [baz]'
    end

    it 'does not contain creator signature if missing' do
      allow(outgoing_message).to receive(:message_has_creator?).and_return(false)
      expect(outgoing_message.text).to eq 'foobar'
    end
  end

  describe '#message_has_creator?' do
    it 'is truthy if creator is present' do
      allow(message).to receive(:created_by_id).and_return(create(:user).id)
      expect(outgoing_message.message_has_creator?).to be true
    end

    it 'is falsey if creator is missing' do
      allow(message).to receive(:created_by_id).and_return(nil)
      expect(outgoing_message.message_has_creator?).to be false
    end
  end

  describe '#creator_signature' do
    let(:request) { create :request }
    let(:creator) { create :user }

    it 'is composed of creator name and request organisation name' do
      message.update! request: request, creator: creator
      expect(outgoing_message.creator_signature).to eq "#{message.creator.to_s}, #{request.organisation.name}"
    end

    it 'is composed of request organisation name if creator is missing' do
      message.update! request: request
      expect(outgoing_message.creator_signature).to eq request.organisation.name
    end

    it 'is composed of creator name if request organisation is missing' do
      message.update! creator: creator
      expect(outgoing_message.creator_signature).to eq creator.to_s
    end

    it 'is empty when no data are present' do
      expect(outgoing_message.creator_signature).to eq ''
    end
  end
end
