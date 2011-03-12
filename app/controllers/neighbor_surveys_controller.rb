class NeighborSurveysController < ApplicationController
  # GET /neighbor_surveys
  # GET /neighbor_surveys.xml
  def index
    @neighbor_surveys = NeighborSurvey.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @neighbor_surveys }
    end
  end

  # GET /neighbor_surveys/1
  # GET /neighbor_surveys/1.xml
  def show
    @neighbor_survey = NeighborSurvey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @neighbor_survey }
    end
  end

  # GET /neighbor_surveys/new
  # GET /neighbor_surveys/new.xml
  def new
    @neighbor_survey = NeighborSurvey.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @neighbor_survey }
    end
  end

  # GET /neighbor_surveys/1/edit
  def edit
    @neighbor_survey = NeighborSurvey.find(params[:id])
  end

  # POST /neighbor_surveys
  # POST /neighbor_surveys.xml
  def create
    @neighbor_survey = NeighborSurvey.new(params[:neighbor_survey])

    respond_to do |format|
      if @neighbor_survey.save
        format.html { redirect_to(@neighbor_survey, :notice => 'NeighborSurvey was successfully created.') }
        format.xml  { render :xml => @neighbor_survey, :status => :created, :location => @neighbor_survey }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @neighbor_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /neighbor_surveys/1
  # PUT /neighbor_surveys/1.xml
  def update
    @neighbor_survey = NeighborSurvey.find(params[:id])

    respond_to do |format|
      if @neighbor_survey.update_attributes(params[:neighbor_survey])
        format.html { redirect_to(@neighbor_survey, :notice => 'NeighborSurvey was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @neighbor_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /neighbor_surveys/1
  # DELETE /neighbor_surveys/1.xml
  def destroy
    @neighbor_survey = NeighborSurvey.find(params[:id])
    @neighbor_survey.destroy

    respond_to do |format|
      format.html { redirect_to(neighbor_surveys_url) }
      format.xml  { head :ok }
    end
  end
end
