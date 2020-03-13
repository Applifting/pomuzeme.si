class HomeController < ApplicationController

  def index
    session[:test] = Time.now
  end

  def test_set
    session[:test] = Time.now
  end

  def test_post
    puts session[:test]
    head :ok
  end
end