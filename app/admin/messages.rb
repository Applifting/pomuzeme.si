# frozen_string_literal: true

ActiveAdmin.register Message do
  belongs_to :volunteer

  permit_params :volunteer_id, :request_id, :created_by_id, :text

  controller do
    def create
      super do |success, failure|
        success.html do
          redirect_to new_admin_volunteer_message_path(params[:volunteer_id], request_id: params[:message][:request_id]), notice: 'Zpráva odeslána'
        end
        failure.html { render :new }
      end
    end
  end

  form do |f|
    # Mark incoming messages as read
    Message.incoming.unread.for_request(params[:request_id], params[:volunteer_id]).update_all(read_at: Time.zone.now)

    groupped_messages = Message.for_request(params[:request_id], params[:volunteer_id]).order(:created_at).decorate.group_by { |msg| msg.created_at.to_date }

    render partial: 'messages', locals: { groupped_messages: groupped_messages }

    f.inputs 'Nová zpráva' do
      f.input :text
      f.input :request_id, as: :hidden, input_html: { value: params[:request_id] }
      f.input :created_by_id, as: :hidden, input_html: { value: current_user.id }
      custom_input :redirect_to, type: :hidden, value: request.referrer
    end
    f.actions do
      f.action :submit
      f.action :cancel, as: :link, label: 'Zpět do poptávky', url: admin_organisation_request_path(params[:request_id])
    end
  end
end
