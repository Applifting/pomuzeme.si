# frozen_string_literal: true

ActiveAdmin.register Message do
  belongs_to :volunteer

  permit_params :volunteer_id, :request_id, :created_by_id, :text, :status

  controller do
    def create
      super do |success, failure|
        success.html do
          original_referrer = params[:message][:redirect_to]
          redirect = original_referrer && URI(original_referrer).path

          redirect_to redirect, notice: 'Zpráva odeslána'
        end
        failure.html { render :new }
      end
    end

    def destroy
      super do |success, failure|
        success.html { redirect_to admin_group_path(resource.group_id) }
        failure.html { render :new }
      end
    end
  end

  form do |f|
    f.inputs 'Nová zpráva' do
      f.input :text
      f.input :request_id, as: :hidden, input_html: { value: params[:request_id] }
      f.input :created_by_id, as: :hidden, input_html: { value: current_user.id }
      f.input :status, as: :hidden, input_html: { value: :pending }
      custom_input :redirect_to, type: :hidden, value: request.referrer
    end
    f.actions
  end
end
