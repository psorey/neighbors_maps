require 'mapscript'
include Mapscript

class ThemeMapsController < ApplicationController
  # GET /theme_maps
  # GET /theme_maps.xml
  def index
    @theme_maps = ThemeMap.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @theme_maps }
    end
  end

  # GET /theme_maps/1
  # GET /theme_maps/1.xml
  def show
    @theme_map = ThemeMap.find(params[:id])
    # now build the map_object and render it
    @layer_list = @theme_map.make_mapfile
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @theme_map }
    end
  end

  # GET /theme_maps/new
  # GET /theme_maps/new.xml
  def new
    #logger.debug "about to list layers"
    #redirect_to :controller => "map_layers", :action => "index" and return
    #logger.debug "returned from map_layers"
    
    @theme_map = ThemeMap.new
    @map_layers = MapLayer.find(:all, :order => 'name')
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @theme_map }
    end
  end

  # GET /theme_maps/1/edit
  def edit
    @theme_map = ThemeMap.find(params[:id])
  end

  # POST /theme_maps
  # POST /theme_maps.xml
  def create
    @theme_map = ThemeMap.new(params[:theme_map])
    @theme_map.save  # so we get an id...

    map_layers = ['Bus Routes', 'Project Boundary', 'Neighbors']
    map_layers.each do |layer|
      map_layer = MapLayer.find(:first, :conditions => { :name => layer})
      if map_layer
        theme_map_layer = @theme_map.theme_map_layers.create(:map_layer => map_layer)
        #@theme_map.map_layers << map_layer
      end
    end

    respond_to do |format|
      if @theme_map.save
        format.html { redirect_to(@theme_map, :notice => 'ThemeMap was successfully created.') }
        format.xml  { render :xml => @theme_map, :status => :created, :location => @theme_map }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @theme_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /theme_maps/1
  # PUT /theme_maps/1.xml
  def update
    @theme_map = ThemeMap.find(params[:id])

    respond_to do |format|
      if @theme_map.update_attributes(params[:theme_map])
        format.html { redirect_to(@theme_map, :notice => 'ThemeMap was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @theme_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /theme_maps/1
  # DELETE /theme_maps/1.xml
  def destroy
    @theme_map = ThemeMap.find(params[:id])
    @theme_map.destroy

    respond_to do |format|
      format.html { redirect_to(theme_maps_url) }
      format.xml  { head :ok }
    end
  end
end
