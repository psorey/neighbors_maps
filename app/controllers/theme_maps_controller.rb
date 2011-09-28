
class ThemeMapsController < ApplicationController
  
  def index
    @theme_maps = ThemeMap.all
  end


  def show
    @theme_map = ThemeMap.find_by_slug(params[:id])
    # build the map_object and write it to a mapfile for Mapserver
    @theme_map.make_mapfile
  end


  def new
    @theme_map = ThemeMap.new
    @map_layers = MapLayer.find(:all, :order => 'name')
  end


  def edit
    @theme_map = ThemeMap.find_by_slug(params[:id])
    @theme_layers, @theme_layer_ids, @base_layer_ids = @theme_map.get_theme_layers
    @map_layers = MapLayer.find(:all, :order => 'name')
  end


  def create
    @theme_map = ThemeMap.new(params[:theme_map])
    @theme_map.save  # so we get an id...
    map_layers = params[:layers][:layer_ids]
    base_layers = params[:base_layers][:layer_ids]
    @theme_map.update_layers(map_layers, base_layers)
    if @theme_map.save
      redirect_to(@theme_map, :notice => 'ThemeMap was successfully created.') 
    else
      render :action => "new" 
    end
  end


  def update
    @theme_map = ThemeMap.find_by_slug(params[:id])
    map_layers = params[:layers][:layer_ids]
    base_layers = params[:base_layers][:layer_ids]
    @theme_map.update_layers(map_layers, base_layers)
    @theme_map.save
    if @theme_map.update_attributes(params[:theme_map])
      redirect_to(@theme_map, :notice => 'ThemeMap was successfully updated.')
    else
       render :action => "edit"
    end
  end


  def destroy
    @theme_map = ThemeMap.find_by_slug(params[:id])
    @theme_map.destroy
    redirect_to(theme_maps_url) 
  end
end
