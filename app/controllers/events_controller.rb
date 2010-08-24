class EventsController < ApplicationController
  
  def index
    redirect_to :controller => 'welcome', :action => 'index'
  end
  
end
