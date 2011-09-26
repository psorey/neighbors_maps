class ThemeMapLayersController < ApplicationController
  # GET /theme_map_layers
  # GET /theme_map_layers.xml
  def index
    @theme_map_layers = ThemeMapLayer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @theme_map_layers }
    end
  end

  # GET /theme_map_layers/1
  # GET /theme_map_layers/1.xml
  def show
    @theme_map_layer = ThemeMapLayer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @theme_map_layer }
    end
  end

  # GET /theme_map_layers/new
  # GET /theme_map_layers/new.xml
  def new
    @theme_map_layer = ThemeMapLayer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @theme_map_layer }
    end
  end

  # GET /theme_map_layers/1/edit
  def edit
    @theme_map_layer = ThemeMapLayer.find(params[:id])
  end

  # POST /theme_map_layers
  # POST /theme_map_layers.xml
  def create
    @theme_map_layer = ThemeMapLayer.new(params[:theme_map_layer])

    respond_to do |format|
      if @theme_map_layer.save
        format.html { redirect_to(@theme_map_layer, :notice => 'ThemeMapLayer was successfully created.') }
        format.xml  { render :xml => @theme_map_layer, :status => :created, :location => @theme_map_layer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @theme_map_layer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /theme_map_layers/1
  # PUT /theme_map_layers/1.xml
  def update
    @theme_map_layer = ThemeMapLayer.find(params[:id])

    respond_to do |format|
      if @theme_map_layer.update_attributes(params[:theme_map_layer])
        format.html { redirect_to(@theme_map_layer, :notice => 'ThemeMapLayer was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @theme_map_layer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /theme_map_layers/1
  # DELETE /theme_map_layers/1.xml
  def destroy
    @theme_map_layer = ThemeMapLayer.find(params[:id])
    @theme_map_layer.destroy

    respond_to do |format|
      format.html { redirect_to(theme_map_layers_url) }
      format.xml  { head :ok }
    end
  end
end
