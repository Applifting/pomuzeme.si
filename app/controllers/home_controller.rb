class HomeController < ApplicationController

  def index
    session[:volunteer] = nil
  end
end