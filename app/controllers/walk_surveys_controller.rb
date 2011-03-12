class WalkSurveysController < ApplicationController
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
    @walk_survey = WalkSurvey.new
    @neighbor_id = '2'
    @existing_lines = WalkSurvey.find(:all, :conditions => {:neighbor_id => '2'})
    @lines = []
    @freqs = []
    @existing_lines.each do |ws|
      @lines << ws.routes.as_wkt()
      @freqs << ws.route_frequencies
    end
    @javascript_lines = "['#{@lines.join('\',\'')}']"
    @javascript_freqs = "['#{@freqs.join('\',\'')}']"

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
    #@walk_survey = WalkSurvey.new(params[:walk_survey])
    #logger.debug("creating paths = #{params[:line][:route]}")
    routes = JSON.parse(params[:line][:route])
    frequencies = JSON.parse(params[:line2][:frequency])
    #logger.debug "routes="
    #route_string = ''
    success = 1
    for i in 0..routes.length - 1
      walk_survey = WalkSurvey.new
      walk_survey.route = Geometry.from_ewkt(routes[i])
      walk_survey.route.srid = 4326
      walk_survey.frequency = frequencies[i]
      walk_survey.neighbor_id = 2
      if !walk_survey.save
        success = 0
      end
    end
    #routes.each do |p|
    #  logger.debug p
      #route_string += p
      #route_string += ';'
    #end
    #logger.debug "route string = #{route_string}"
    #logger.debug "frequencies="
    #frequencies.each do |f|
    #  logger.debug f
    #end

    #line = Geometry.from_ewkt(route_string)
    #line.srid = 4326
    #@walk_survey.route = line
    
    #@walk_survey.routes = ST_LineFromText(routes,4326)
    
    respond_to do |format|
      if success
        format.html { render :action => 'new', :notice => 'routes were successfully updated.' }
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
