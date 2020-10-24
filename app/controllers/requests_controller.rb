class RequestsController < PublicController
  skip_before_action :authorize_current_volunteer, except: [:accept]

  def index
    @requests            = Request.includes(:address, :requested_volunteers, :organisation)
                                  .assignable
                                  .order(created_at: :desc)
    @all_requests_count  = Request.assignable.count
  end

  def accept
    check_request_permissions

    volunteer_already_accepted = RequestedVolunteer.where(volunteer: @current_volunteer, request_id: params[:request_id].to_i).present?


    if volunteer_already_accepted
      flash[:warn] = 'Tuto žádost už jste jednou přijal/a.'
    else
      add_volunteer_to_request
      log_acceptance_message

      flash[:success] = 'Děkujeme. Vaše kontaktní údaje předáme koordinátorovi poptávky, který se vám brzy ozve.'
    end

    redirect_to requests_path
  end

  private

  def add_volunteer_to_request
    RequestedVolunteer.create! volunteer: @current_volunteer,
                               request_id: params[:request_id],
                               state: :accepted
  end

  def log_acceptance_message
    message = Message.create! volunteer: @current_volunteer,
                              request_id: params[:request_id],
                              direction: :incoming,
                              state: :received,
                              channel: :sms,
                              text: 'Ano'

    Messages::ReceivedProcessorJob.perform_later message
  end

  def check_request_permissions
    request_permitted = Request.assignable.where(id: params[:request_id].to_i).present?

    return true if request_permitted

    flash[:success] = 'Tuto žádost se nepodařilo přidělit.'
    Raven.capture_exception StandardError.new('Request cannot be found')
    redirect_to(requests_path) && return
  end
end