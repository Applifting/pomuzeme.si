# frozen_string_literal: true

ActiveAdmin.register Message, as: 'Subscriber Message' do
  permit_params :request_id, :created_by_id, :text, :channel, :message_type

  controller do
    def create
      # Potentional vulnerability due to trusting permitted_params values
      MessagingService.create_message permitted_params[:message]
      redirect_to new_admin_subscriber_message_path(request_id: params[:message][:request_id],
                                                    subscriber_phone: params[:message][:phone]), notice: 'Zpráva odeslána'
    rescue StandardError => e
      redirect_to new_admin_subscriber_message_path(request_id: params[:message][:request_id],
                                                    subscriber_phone: params[:message][:phone]), alert: e.message
    end
  end

  form do |f|
    # Mark incoming messages as read
    volunteer_request = Request.find(params[:request_id])
    volunteer_request.subscriber_messages.incoming.unread.each { |message| message.update read_at: Time.zone.now }

    groupped_messages = volunteer_request.subscriber_messages
                                         .eager_load(:creator)
                                         .order(:created_at)
                                         .decorate.group_by { |msg| msg.created_at.to_date }

    panel 'Konverzace s příjemcem' do
      render partial: 'admin/messages/messages', locals: { groupped_messages: groupped_messages }
    end

    f.inputs 'Nová zpráva' do
      f.input :text
      f.input :request_id, as: :hidden, input_html: { value: params[:request_id] }
      f.input :created_by_id, as: :hidden, input_html: { value: current_user.id }
      f.input :channel, as: :hidden, input_html: { value: :sms }
      f.input :message_type, as: :hidden, input_html: { value: :subscriber }
      f.input :phone, as: :hidden, input_html: { value: params[:subscriber_phone] }
      custom_input :redirect_to, type: :hidden, value: request.referrer
    end
    f.actions do
      f.action :submit
      f.action :cancel, as: :link, label: 'Zpět do poptávky', url: admin_organisation_request_path(params[:request_id])
    end
  end
end
