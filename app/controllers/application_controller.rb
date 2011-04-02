# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Be sure to include AuthenticationSystem in Application Controller
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem


  layout 'overall'
  
	class Helper
		include Singleton
		include ActionView::Helpers::TextHelper
		
	end
  
  def help
    Helper.instance
  end


  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

	def access_denied
		alias new_session_path login_path
		super
	end

end

