class CallbackController < ApplicationController
  protect_from_forgery except: :sms

  def sms
    puts params
    head :ok
  end

end