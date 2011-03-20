class WalkSurveysController < ApplicationController
  
  
  before_filter :login_required
  
  
  # GET /walk_surveys
  # GET /walk_surveys.xml
  def index
    @walk_surveys = WalkSurvey.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @walk_surveys }
    end
  end


  # GET /walk_surveys/1
  # GET /walk_surveys/1.xml
  def show
    @walk_survey = WalkSurvey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @walk_survey }
    end
  end


  # GET /walk_surveys/new
  # GET /walk_surveys/new.xml
  def new
    @walk_survey = WalkSurvey.new  # remove; this is unnecessary. use 
    @current_neighbor_id = '2'  # !!! for testing
    
    existing_mapped_lines = MappedLine.find(:all, :conditions =>
       {:owner_id => @current_neighbor_id, :map_layer_id => 'walk_survey'})
    
    # back to erasing and re-filling the database with the lines each time...
    # sending just the relevant information via JSON,
    # not the whole mapped_line object which may grow

    geometry_list  = []
    end_label_list = []
    
    existing_mapped_lines.each do |mapped_line|
      geometry_list       << mapped_line.geometry.as_wkt()
      end_label_list      << mapped_line.end_label
    end
    
    @json_geometry = geometry_list.to_json
    @json_frequencies = end_label_list.to_json

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @walk_survey }
    end
  end


  # GET /walk_surveys/1/edit
  def edit
    @walk_survey = WalkSurvey.find(params[:id])
  end


  # POST /walk_surveys
  # POST /walk_surveys.xml
  def create
    @current_neighbor_id = '2'
    @walk_survey = WalkSurvey.new(params[:walk_survey])
    # logger.debug("creating paths = #{params[:line][:route]}")
    routes = JSON.parse(params[:line][:route])
    frequencies = JSON.parse(params[:line2][:frequency])

    success = 1
    
    MappedLine.destroy_all(:owner_id => @current_neighbor_id, :map_layer_id => 'walk_survey')

    for i in 0..routes.length - 1
      if frequencies[i] == nil
        #do nothing
      else
        mapped_line = MappedLine.new
        mapped_line.geometry = Geometry.from_ewkt(routes[i])
        mapped_line.geometry.srid = 4326
        mapped_line.end_label = frequencies[i]
        mapped_line.owner_id = @current_neighbor_id
        mapped_line.map_layer_id = 'walk_survey'
  
        if !mapped_line.save
          success = 0
        end
      end
    end
    
    respond_to do |format|
      if success

        format.html { redirect_to :action => 'new', :notice => 'routes were successfully updated.' }
        #format.xml  { render :xml => @walk_survey, :status => :created, :location => @walk_survey }
      else
        format.html { render :action => "new", :notice => 'an error occurred'}
        #format.xml  { render :xml => @walk_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /walk_surveys/1
  # PUT /walk_surveys/1.xml
  def update
    @walk_survey = WalkSurvey.find(params[:id])

    respond_to do |format|
      if @walk_survey.update_attributes(params[:walk_survey])
        format.html { redirect_to(@walk_survey, :notice => 'WalkSurvey was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @walk_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /walk_surveys/1
  # DELETE /walk_surveys/1.xml
  def destroy
    @walk_survey = WalkSurvey.find(params[:id])
    @walk_survey.destroy

    respond_to do |format|
      format.html { redirect_to(walk_surveys_url) }
      format.xml  { head :ok }
    end
  end
end
