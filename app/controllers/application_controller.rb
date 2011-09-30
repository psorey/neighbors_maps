# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Be sure to include AuthenticationSystem in Application Controller
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem


=begin  a controller variable accessible from the view...
class Account < ActiveRecord::Base
  cattr_accessor :current
end


  before_filter :set_current_account
  def set_current_account
    #  set @current_account from session data here
    Account.current = @current_account
  end

=end


  layout 'overall'
  
  def initialize
    Rails.logger.info("PARAMS: #{params.inspect}")		
  end


	class Helper
		include Singleton
		include ActionView::Helpers::TextHelper
		
	end
  
  def help
    Helper.instance
  end


  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

	def access_denied
		alias new_session_path login_path
		super
	end

end

