require 'bluecloth'
#require 'log_buddy/init'


class ThemeMapsController < ApplicationController


  layout "theme_maps_layout", only: :show
  # before_filter :login_required, except: 'index'
  before_filter :set_current_user


  def set_current_user
    @current_neighbor_id = 44
    logger.debug "set current user"
  end


  def index
    @interactive_theme_maps = ThemeMap.where(is_interactive: true).order("name ASC")
    @theme_maps = ThemeMap.where(is_interactive: false).order("name ASC")
  end


  def show
    @theme_map = ThemeMap.where(slug: params[:id]).first
    # build the map_object and write it to a mapfile for Mapserver
    d{@theme_map}
    @theme_map.make_mapfile
    if @theme_map.is_interactive
      build_geometry_json
    end
  end


  def new
    @theme_map = ThemeMap.new
    @map_layers = MapLayer.order('name ASC')
  end


  def create
    @theme_map = ThemeMap.new(theme_map_params)
    map_layer_ids = params[:layer_ids]
    map_layer_ids.each do |map_layer_id|
      new_layer = ThemeMapLayer.new
      new_layer.is_base_layer = false
      new_layer.map_layer_id = map_layer_id
      @theme_map.theme_map_layers << new_layer
    end
    base_layer_ids = params[:base_layer_ids]
    base_layer_ids.each do |map_layer_id|
      new_layer = ThemeMapLayer.new
      new_layer.is_base_layer = true
      new_layer.map_layer_id = map_layer_id
      @theme_map.theme_map_layers << new_layer
    end
    @theme_map.create_slug
    if @theme_map.save!
      redirect_to(@theme_map, notice: "'#{@theme_map.name}' was successfully created.")
    else
      @map_layers = MapLayer.order('name ASC')
      render "new"
    end
  end


  def edit
    @theme_map = ThemeMap.where(slug: params[:id]).first
    @theme_layer_ids, @base_layer_ids = @theme_map.get_theme_layers
    @map_layers = MapLayer.order('name ASC')
  end


  def build_geometry_json
    @json_geometries = []
    @json_labels = []
    existing_mapped_lines = MappedLine.where(owner_id: @current_neighbor_id.to_s, map_layer_id: @theme_map.name.dashed)
    unless existing_mapped_lines[0]
      @json_geometries[0] = "none found"
      @json_labels[0] = "none found"
      return
    end
#    geometry_list  = []
#    end_label_list = []
    existing_mapped_lines.each do |mapped_line|
      d{ mapped_line.geometry.as_text}
      @json_geometries   << mapped_line.geometry.as_text
      @json_labels  << mapped_line.end_label
    end
    d{@json_geometries}
    d{@json_labels}
  end
  def send_help
    @theme_map = ThemeMap.where(slug: params[:id]).first
    render :text => BlueCloth.new(@theme_map.description).to_html
  end


  def revert_geo_db
    logger.debug "revert_geo_db"
    logger.debug params.inspect
    @theme_map = ThemeMap.where(:slug => params[:id]).first
    @current_neighbor_id = 44 # current_user.neighbor_id
    build_geometry_json
    render :js => "exist_geometries = #{@json_geometries}; exist_labels = #{@json_labels}; buildFeatures();"
  end


  def update_geo_db
    logger.debug('update_geo_db')
    json = JSON.parse params[:features]
    #logger.debug(json)
    gjson = RGeo::GeoJSON.decode( json, json_parser: :json)
    logger.debug(gjson)
    gjson.each do |f|
      logger.debug(f.inspect)
      logger.debug(f.properties.inspect)
    end
    return
    @theme_map = ThemeMap.where(slug: params[:slug]).first
    @current_neighbor_id = 44 #current_user.neighbor_id
  #  logger.debug @theme_map.inspect
  #  render :js => "from update_geo_db"
  end


  def update
    @theme_map = ThemeMap.where(slug: params[:id]).first
    map_layers = params[:theme_map][:layer_ids]
    base_layers = params[:theme_map][:base_layer_ids]
    @theme_map.update_layers(map_layers, base_layers)
    @theme_map.save
    if @theme_map.is_interactive

    end
    if @theme_map.update_attributes(theme_map_params)
      redirect_to(@theme_map, :notice => 'ThemeMap was successfully updated.')
    else
      render  "edit"
    end
  end


  def destroy
    @theme_map = ThemeMap.where(slug: params[:id]).first
    @theme_map.destroy!
    redirect_to(theme_maps_url)
  end



  private

  def theme_map_params
    params.require(:theme_map).permit(:name, :description, :slug, :is_interactive, :thumbnail_url, :layer_ids=>[], :base_layer_ids=>[])
  end

end
