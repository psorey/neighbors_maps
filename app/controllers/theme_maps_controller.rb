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
    logger.debug "show!!!"
    logger.debug @theme_map.inspect
    @theme_map.make_mapfile
    logger.debug "after make mapfile"
    if @theme_map.is_interactive
      build_geometry_json
      logger.debug "after build geometry"
    end
  end


  def new
    @theme_map = ThemeMap.new
    @map_layers = MapLayer.order('name ASC')
  end


  def create
    @theme_map = ThemeMap.new(theme_map_params)
    unless @theme_map.save
      @map_layers = MapLayer.order('name ASC')
      render "new" and return
    end
    map_layers = params[:theme_map][:layer_ids]
    base_layers = params[:theme_map][:base_layer_ids]
    @theme_map.update_layers(map_layers, base_layers)
    if @theme_map.save
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


  def send_help
    @theme_map = ThemeMap.where(slug: params[:id]).first
    render :text => BlueCloth.new(@theme_map.description).to_html
  end


  def revert_geo_db
    @theme_map = ThemeMap.where(slug: params[:id]).first
    @current_neighbor_id = 44 # current_user.neighbor_id
    build_geometry_json
    render :js => "exist_geometries = #{@json_geometries}; exist_labels = #{@json_labels}; buildFeatures();"
  end


  def update_geo_db
    logger.debug "made it to update_geo_db ##############   ###################   ####################"
    @theme_map = ThemeMap.where(slug: params[:slug]).first
    logger.debug "update_geo_db:"
    logger.debug @theme_map.inspect
    logger.debug "geometries -- convert to array of linestrings"
    logger.debug params[:geometries]
    logger.debug params[:labels]

    @current_neighbor_id = 44 #current_user.neighbor_id
    geometries = JSON.parse(params[:geometries])
    labels = JSON.parse(params[:labels])

    ## !!! rst = MappedLine.destroy_all(owner_id: @current_neighbor_id.to_s, map_layer_id: @theme_map.name.dashed)
    #  wkt = RGeo::WKRep::WKTParser.new
    # mapped_line.geometry = geometries wkt.parse(geometries)
    #  end

    logger.debug "JSON.parse(geometries)"
    d {geometries}
    logger.debug labels
    logger.debug "HERE"
    logger.debug geometries.length
    logger.debug labels.length


    result = 'successfully saved...'
    for i in 0...geometries.length
      #  if labels[i] == nil
      #  do nothing
      #  else
      mapped_line = MappedLine.new
      wkt = RGeo::WKRep::WKTParser.new
      logger.debug "geometries[i]"
      logger.debug geometries[i]
      mapped_line.geometry = wkt.parse(geometries[i])
      mapped_line.geometry = geometries[i]
      mapped_line.end_label = labels[i]
     # current_neighbor_id = current_user.neighbor_id
      mapped_line.owner_id = 44 #current_user.neighbor_id
      mapped_line.map_layer_id = @theme_map.name.dashed
      if !mapped_line.save
        result = 'save failed'
      end
    end
    render :text => result
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
    MappedLine.destroy_all(:map_layer_id => @theme_map.name.dashed)
    @theme_map.destroy
    redirect_to(theme_maps_url)
  end


  def build_geometry_json
    @json_geometries = []
    @json_labels = []
    existing_mapped_lines = MappedLine.where(owner_id: @current_neighbor_id.to_s, map_layer_id: @theme_map.name.dashed)
    logger.debug "existing mapped lines:"
    logger.debug existing_mapped_lines
    unless existing_mapped_lines[0]
      @json_geometries[0] = "none found"
      @json_labels[0] = "none found"
      logger.debug "none found"
      return
    end
    geometry_list  = []
    end_label_list = []
    existing_mapped_lines.each do |mapped_line|
      logger.debug "mapped line geometry:"
      logger.debug mapped_line.geometry.inspect
      d{ mapped_line.geometry.as_text}
      @json_geometries   << mapped_line.geometry.as_text
      @json_labels  << mapped_line.end_label
    end
    d{@json_geometries}
    d{@json_labels}
  end

  private

  def theme_map_params
    hash = {}
    hash.merge! params.require(:theme_map).permit(:name, :description, :slug, :is_interactive)
    hash.merge! params.permit(:layer_ids, :base_layer_ids)
    logger.debug hash
    hash
    #params.require(:theme_map).permit(:name, :description, :slug, :is_interactive, :layer_ids, :base_layer_ids)
  end
 #def some_params
 # hash = {}
#  hash.merge! params.require(:user).slice(:attribute1, :attribute2, :attribute3)
#  hash.merge! params.slice(:attribute_not_on_user_model1,
#  attribute_not_on_user_model2)
#  hash
# end


end
