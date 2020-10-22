require 'rails_helper'

describe Messages::ReceivedProcessorJob do
  before(:all) { I18n.locale = :cs }

  describe '#perform' do
    let(:requested_volunteer) { create :requested_volunteer, :notified }
    let(:request) { requested_volunteer.request }
    let(:volunteer) { requested_volunteer.volunteer }
    let(:unrequested_volunteer) { create :requested_volunteer, :accepted }
    let(:message) { proc { |volunteer, text| create :response_to_offer, text: text, volunteer: volunteer, request: request } }

    context "when we're waiting for volunteer's response (requested_volunteer has status notified)" do
      context 'when response is recognized as confirmation or rejection' do
        it 'calls Common::Request::ResponseProcessor to process the message' do
          response_processor_dbl = double('ResponseProcessor')
          allow(response_processor_dbl).to receive(:perform)
          expect(Common::Request::ResponseProcessor).to receive(:new)
            .with(request, volunteer, true)
            .and_return(response_processor_dbl)
          Messages::ReceivedProcessorJob.new.perform message[volunteer, 'ano']
        end

        it 'marks incoming rejection message as read' do
          incoming_msg = message[volunteer, 'ne']
          expect(incoming_msg.read_at).to be_nil

          Messages::ReceivedProcessorJob.new.perform incoming_msg

          expect(incoming_msg.read_at).not_to be_nil
        end

        it 'leaves incoming acceptance message unread' do
          incoming_msg = message[volunteer, 'ano']
          expect(incoming_msg.read_at).to be_nil

          Messages::ReceivedProcessorJob.new.perform incoming_msg

          expect(incoming_msg.read_at).to be_nil
        end

        it 'leaves other incoming message unread' do
          incoming_msg = message[volunteer, 'nevim']
          expect(incoming_msg.read_at).to be_nil

          Messages::ReceivedProcessorJob.new.perform incoming_msg

          expect(incoming_msg.read_at).to be_nil
        end

        it 'creates acceptance confirmation msg when offer is accepted' do
          Messages::ReceivedProcessorJob.new.perform message[volunteer, 'ano']

          acceptance_confirmation = Message.where(volunteer: volunteer, request: request, direction: :outgoing).first
          expect(acceptance_confirmation.text).to include 'Díky za potvrzení poptávky'
        end

        it 'creates rejection confirmation msg when offer is rejected' do
          Messages::ReceivedProcessorJob.new.perform message[volunteer, 'ne']

          acceptance_confirmation = Message.where(volunteer: volunteer, request: request, direction: :outgoing)
          expect(acceptance_confirmation.count).to eq 1
          expect(acceptance_confirmation.first.text).to include('byla odmítnuta')
        end
      end

      context 'when response is not recognized as confirmation or rejection' do
        it 'asks volunteer to respond with yes / no' do
          expect(SmsService).to receive(:send_text)
            .with(volunteer.phone, 'Máte-li o poptávku zájem, odpovězte ANO nebo NE')

            Messages::ReceivedProcessorJob.new.perform message[volunteer, 'nevim']
        end
      end
    end
  end
end
