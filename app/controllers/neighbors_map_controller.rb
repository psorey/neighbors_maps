class NeighborsMapController < ApplicationController
	
	def index
		
		@mapserver_url = APP_CONFIG['MAPSERVER_URL']
	
	end
	
end
