class RequestsController < PublicController
  skip_before_action :authorize_current_volunteer, except: [:accept]

  def index
    @requests            = Request.for_web.decorate
    @all_requests_count  = Request.for_web.count
  end

  def accept
    redirect_to(requests_path) && return unless request_permissible

    volunteer_already_accepted = RequestedVolunteer.where(volunteer: @current_volunteer, request_id: params[:request_id].to_i).present?


    if volunteer_already_accepted
      flash[:warn] = 'Tuto žádost už jste jednou přijal/a.'
    else
      add_volunteer_to_request
      log_acceptance_message

      flash[:success] = 'Děkujeme. Vaše kontaktní údaje předáme koordinátorovi, který se vám brzy ozve.'
    end

    redirect_to requests_path
  end

  private

  def add_volunteer_to_request
    # Volunteer is created in notified state which is later updated by ReceivedProcessorJob
    RequestedVolunteer.create! volunteer: @current_volunteer,
                               request_id: params[:request_id],
                               state: :notified
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

  def request_permissible
    request_permitted = Request.assignable.where(id: params[:request_id].to_i).present?

    return true if request_permitted

    flash[:error] = 'Tuto žádost se nepodařilo přidělit.'
    Raven.capture_exception StandardError.new('Request cannot be found')
    false
  end
end