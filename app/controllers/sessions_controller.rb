# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
    
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      #redirect_back_or_default('/')
      if user.neighbor_id == nil
        logger.debug ">>>>> user.neighbor_id is NIL!!!"
        neighbor = Neighbor.new
        user.neighbor_id = neighbor.id
        neighbor.save!
        user.save!
        flash[:notice] = "Logged in successfully"
        redirect_to "/welcome" and return
      end
      if user.has_role? "admin"
      flash[:notice] = "Logged in successfully"
       redirect_to "/administrators" and return
      else
        flash[:notice] = "Logged in successfully"
        redirect_to "/welcome" and return
      end

    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'. Maybe you used the wrong password. Maybe you need to activate your account. Check your email!"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
