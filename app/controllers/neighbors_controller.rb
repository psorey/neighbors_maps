require 'spatial_adapter/postgresql'
require 'rubygems'
require 'curl'
#require 'json'
require 'proj4'

class NeighborsController < ApplicationController
  # GET /neighbors
  # GET /neighbors.xml
  def index
    @neighbors = Neighbor.all
    logger.debug " ---------------- Neighbor = #{@neighbors.inspect}"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @neighbors }
    end
  end

  # GET /neighbors/1
  # GET /neighbors/1.xml
  def show
    @neighbor = Neighbor.find(params[:id])
    logger.debug " ---------------- Neighbor = #{@neighbor.inspect}"

    get_block_id
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @neighbor }
    end
  end


  # GET /neighbors/new
  # GET /neighbors/new.xml
  def new
    
    @neighbor = Neighbor.new

    @neighbor.volunteer = []
    @neighbor.improvements = []
    @neighbor.why_walk = []
    @neighbor.dont_walk = []


    @volunteer = []
    @improvements = []
    @why_walk = []
    @dont_walk = []

    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @neighbor }
    end
  end

  # GET /neighbors/1/edit
  def edit
		
    @neighbor = Neighbor.find(params[:id])
    
    if @neighbor.improvements == nil
			@neighbor.improvements = []
    end
    if @neighbor.volunteer == nil
			@neighbor.volunteer = []
    end
    if @neighbor.why_walk == nil
			@neighbor.why_walk = []
    end
    if @neighbor.dont_walk == nil
			@neighbor.dont_walk = []
    end
    
  end

  # POST /neighbors
  # POST /neighbors.xml
  def create
    @neighbor = Neighbor.new(params[:neighbor])
    @neighbor.improvements = params[:improvements]
    @neighbor.volunteer = params[:volunteer]
    @neighbor.why_walk = params[:why_walk]
    @neighbor.dont_walk = params[:dont_walk]

    get_block_id


    respond_to do |format|
      if @neighbor.save
        flash[:notice] = 'Neighbor was successfully created.'
        format.html { redirect_to(@neighbor) }
        format.xml  { render :xml => @neighbor, :status => :created, :location => @neighbor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @neighbor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /neighbors/1
  # PUT /neighbors/1.xml
  def update
    @neighbor = Neighbor.find(params[:id])
    @neighbor.improvements = params[:improvements]
    @neighbor.volunteer = params[:volunteer]
    @neighbor.why_walk = params[:why_walk]
    @neighbor.dont_walk = params[:dont_walk]
    
    get_block_id
    
    respond_to do |format|
      if @neighbor.update_attributes(params[:neighbor])
        flash[:notice] = 'Neighbor was successfully updated.'
        format.html { redirect_to(@neighbor) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @neighbor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /neighbors/1
  # DELETE /neighbors/1.xml
  def destroy
    @neighbor = Neighbor.find(params[:id])
    @neighbor.destroy

    respond_to do |format|
      format.html { redirect_to(neighbors_url) }
      format.xml  { head :ok }
    end
  end


protected

  def get_block_id
    @address_string = @neighbor.get_address_string
    geoJson= Curl::Easy.perform("http://maps.google.com/maps/api/geocode/json?address=#{@address_string}&sensor=false")
    json = geoJson.body_str
    parsed_json = JSON(json)
    results = parsed_json.fetch 'results'
    lat = results[0]["geometry"]["location"]["lat"].to_f
    lon = results[0]["geometry"]["location"]["lng"].to_f
		
		srcPoint = Proj4::Point.new(Math::PI * lon / 180, Math::PI * lat / 180)
		destPrj = Proj4::Projection.new("+proj=lcc +lat_1=47.5 +lat_2=48.73333333333333 +lat_0=47 +lon_0=-120.8333333333333 +x_0=500000.0000000002 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs")
		point = destPrj.forward(srcPoint)
		
    @neighbor.location = Point.from_x_y(point.x, point.y, 4326)
    half_block_id = @neighbor.get_half_block_id
    logger.debug half_block_id
    @neighbor.half_block_id = half_block_id

    @neighbor.save

  end

end