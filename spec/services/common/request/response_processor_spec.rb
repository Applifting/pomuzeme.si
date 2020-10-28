require 'rails_helper'

describe Common::Request::ResponseProcessor do
  before(:all) { I18n.locale = :cs }

  describe '#perform' do
    let(:requested_volunteer) { create :requested_volunteer }
    let(:request) { requested_volunteer.request }
    let(:volunteer) { requested_volunteer.volunteer }
    let(:different_request) { create :request }

    it 'raises exception if volunteer does not have access to request' do
      expect(Message).not_to receive(:create!)
      expect { Common::Request::ResponseProcessor.new(different_request, volunteer, nil).perform }
        .to raise_error(AuthorisationError)
    end

    describe 'subscriber notification' do
      let(:request)             { create :request, :from_organisation, subscriber_phone: '+420777222444' }
      let(:volunteer)           { create :volunteer, first_name: 'John', last_name: 'Barber', phone: '+420777111555' }
      let!(:requested_volunteer) { create :requested_volunteer, request: request, volunteer: volunteer }

      context 'when volunteer accepts request from with subscriber - organisation' do
        it 'sends voluteer contact to request subscriber' do
          text = format 'Na vaší poptávku %{identifier} se přihlásil nový dobrovolník - %{full_name}, %{phone}.',
                  identifier: request.identifier,
                  full_name: volunteer.to_s,
                  phone: volunteer.phone

          expect(Message).to receive(:create!).with(request: request,
                                                    text: text,
                                                    direction: :outgoing,
                                                    message_type: :subscriber,
                                                    channel: :sms,
                                                    phone: '+420777222444')
                                              .and_return(Message.new)

          Common::Request::ResponseProcessor.new(request, volunteer, true).perform
        end
      end
    end

    context 'when volunteer with push notifications accepts' do
      it 'logs accepting response status as message to request (to have a record in the Messages)' do
        volunteer.update preferences: { notifications_to_app: true }

        expect(Message).to receive(:create!).with(volunteer: volunteer,
                                                  request: request,
                                                  text: I18n.t('request.responses.accept'),
                                                  direction: :outgoing,
                                                  state: :received)
        Common::Request::ResponseProcessor.new(request, volunteer.reload, true).perform
      end

      it 'changes request state if capacity is filled' do
        request.searching_capacity!
        allow_any_instance_of(Common::Request::ResponseProcessor)
          .to receive(:original_request_accepted_size).and_return(request.required_volunteer_count - 1)
        expect { Common::Request::ResponseProcessor.new(request, volunteer, true).perform }
          .to change { request.reload.state }.from('searching_capacity').to('pending_confirmation')
      end

      it 'changes request state if capacity is unfilled' do
        request.pending_confirmation!
        expect { Common::Request::ResponseProcessor.new(request, volunteer, false).perform }
          .to change { request.reload.state }.from('pending_confirmation').to('searching_capacity')
      end

      it 'raises exception if capacity would be exceeded' do
        expect(Message).not_to receive(:create!)
        allow_any_instance_of(Common::Request::ResponseProcessor)
            .to receive(:original_request_accepted_size).and_return(request.required_volunteer_count)
        expect { Common::Request::ResponseProcessor.new(request, volunteer, true).perform }
            .to raise_error(Common::Request::CapacityExceededError)
      end

      it 'updates requested volunteer state' do
        expect { Common::Request::ResponseProcessor.new(request, volunteer, true).perform }
          .to change { requested_volunteer.reload.state }.from('pending_notification').to('accepted')
      end
    end

    context 'when user with push notifications rejects' do
      it 'logs rejecting response status as message to request' do
        volunteer.update preferences: { notifications_to_app: true }

        expect(Message).to receive(:create!).with(volunteer: volunteer,
                                                  request: request,
                                                  text: I18n.t('request.responses.rejected'),
                                                  direction: :outgoing,
                                                  state: :received)
        Common::Request::ResponseProcessor.new(request, volunteer, false).perform
      end
      it 'updates requested volunteer state' do
        expect { Common::Request::ResponseProcessor.new(request, volunteer, false).perform }
          .to change { requested_volunteer.reload.state }.from('pending_notification').to('rejected')
      end
    end
  end
end
