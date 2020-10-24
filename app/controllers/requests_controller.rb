class RequestsController < PublicController
  skip_before_action :authorize_current_volunteer

  def index
    @requests            = Request.includes(:address, :requested_volunteers, :organisation)
                                  .assignable
                                  .order(created_at: :desc)
    @all_requests_count  = Request.assignable.count
  end
end