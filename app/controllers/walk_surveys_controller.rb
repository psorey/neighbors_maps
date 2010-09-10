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
    @walk_survey = WalkSurvey.new(params[:walk_survey])
    paths = JSON.parse(params[:line][:paths])
    frequencies = JSON.parse(params[:line2][:frequencies])
    logger.debug "paths:"
    paths.each do |p|
      logger.debug p
    end
    logger.debug "frequencies"
    frequencies.each do |f|
      logger.debug f
    end
    logger.debug "paths = #{paths}"
    logger.debug "frequencies = #{frequencies}"

    #line = Geometry.from_ewkt(wkt)
    #line.srid = 4326
    #@walk_survey.routes = line
    
    # @walk_survey.routes = ST_LineFromText(wkt,4326)
    respond_to do |format|
      if @walk_survey.save
        format.html { redirect_to(@walk_survey, :notice => 'WalkSurvey was successfully created.') }
        format.xml  { render :xml => @walk_survey, :status => :created, :location => @walk_survey }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @walk_survey.errors, :status => :unprocessable_entity }
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
