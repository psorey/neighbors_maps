class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  

  # render new.rhtml
  def new
    @user = User.new
  end
    
  #
  # Change user passowrd
  def change_password
  end
    
    
  #
  # Change user passowrd
  def change_password_update
      if User.authenticate(current_user.login, params[:old_password])
          if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
              current_user.password_confirmation = params[:password_confirmation]
              current_user.password = params[:password]
              
              if current_user.save!
                  flash[:notice] = "Password successfully updated"
                  redirect_to change_password_path
              else
                  flash[:alert] = "Password not changed"
                  render :action => 'change_password'
              end
               
          else
              flash[:alert] = "New Password mismatch" 
              render :action => 'change_password'
          end
      else
          flash[:alert] = "Old password incorrect" 
          render :action => 'change_password'
      end
  end
  
  
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    role = Role.find(:all, :conditions => {:name => 'neighbor'})
    neighbor = Neighbor.new(:user_id => @user.id)
    @user.neighbor_id = neighbor.id
    @user.roles = role
    success = @user && @user.save && neighbor.save
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end


  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to "/neighbors/show/#{user.neighbor_id}"
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end
end

  def update
  end
