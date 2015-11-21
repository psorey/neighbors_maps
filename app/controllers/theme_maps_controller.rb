require 'bluecloth'
#require 'log_buddy/init'


class ThemeMapsController < ApplicationController


  layout "theme_maps_layout", only: :show
  before_filter :login_required, except: 'index'
 # before_filter :set_current_user



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
    @geo_json =  UserLine.load_geo_json
   # @geo_json =  UserLine.test_load

    @theme_map.make_mapfile
    if @theme_map.is_interactive
      #build_geometry_json
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



  def revert_geo_db
    logger.debug "revert_geo_db"
    logger.debug params.inspect
    @theme_map = ThemeMap.where(:slug => params[:id]).first
    @current_neighbor_id = 44    # current_user.neighbor_id
    build_geometry_json
    render :js => "exist_geometries = #{@json_geometries}; exist_labels = #{@json_labels}; buildFeatures();"
  end


  # update_geo_db should load existing lines or
  # should create new lines and give them id's
  # should delete user-deleted lines (no longer sent via json)
  # TODO implement properties: changed, deleted, only update user_lines that change
  # TODO decide if user_feature (point, line or polygon) can replace user_line

  def update_geo_db
    json = JSON.parse params[:features]
    gjson = RGeo::GeoJSON.decode( json, json_parser: :json )
    gjson.each do |feature|
      line = nil
      f_id = feature.properties["id"]
      if f_id != nil
        line = UserLine.find(f_id )
        line.text   = feature.properties["text"]
        line.number = feature.properties["number"]
        # line.amount = feature.properties["amount"]
        # line.name   = feature.properties["name"]
      else
        line = UserLine.new
        line.save
      end
      wkt_string = feature.geometry.as_text
      g_factory = RGeo::Cartesian::Factory.new(srid: 3857)
      line.geometry = g_factory.parse_wkt(wkt_string)
      line.update_attributes(theme_map_params)
    end
    return
    @theme_map = ThemeMap.where(slug: params[:slug]).first
    @current_neighbor_id = 44 #current_user.neighbor_id
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
    params.require(:theme_map).permit(:name, :description, :slug, :is_interactive, :thumbnail_url, :layer_ids=>[], :base_layer_ids=>[],  :user_lines_attributes => [:id, :name, :geometry, :text, :number, :amount, :map_layer_id, :user_id])
  end

end
