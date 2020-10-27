# frozen_string_literal: true

ActiveAdmin.register Message do
  permit_params :volunteer_id, :request_id, :created_by_id, :text, :channel

  controller do
    def create
      # Potentional vulnerability due to trusting permitted_params values
      MessagingService.create_message permitted_params[:message]
      redirect_to new_admin_message_path(volunteer_id: params[:message][:volunteer_id],
                                         request_id: params[:message][:request_id]), notice: 'Zpráva odeslána'
    rescue StandardError => e
      redirect_to new_admin_message_path(volunteer_id: params[:message][:volunteer_id],
                                         request_id: params[:message][:request_id]), alert: e.message
    end
  end

  form do |f|
    # Mark incoming messages as read
    Message.mark_read(request_id: params[:request_id], volunteer_id: params[:volunteer_id])

    groupped_messages = Message.with_request_and_volunteer(request_id: params[:request_id], volunteer_id: params[:volunteer_id])
                               .eager_load(:creator)
                               .order(:created_at)
                               .decorate.group_by { |msg| msg.created_at.to_date }

    panel 'Konverzace s dobrovolníkem' do
      render partial: 'messages', locals: { groupped_messages: groupped_messages }
    end

    f.inputs 'Nová zpráva' do
      f.input :text
      f.input :request_id, as: :hidden, input_html: { value: params[:request_id] }
      f.input :volunteer_id, as: :hidden, input_html: { value: params[:volunteer_id] }
      f.input :created_by_id, as: :hidden, input_html: { value: current_user.id }
      f.input :channel, as: :hidden, input_html: { value: :sms }
      custom_input :redirect_to, type: :hidden, value: request.referrer
    end
    f.actions do
      f.action :submit
      f.action :cancel, as: :link, label: 'Zpět do poptávky', url: admin_organisation_request_path(params[:request_id])
    end
  end
end
