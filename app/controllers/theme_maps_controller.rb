require 'bluecloth'

class ThemeMapsController < ApplicationController


  before_filter :set_current_user


  def set_current_user
    @current_user_id = 44  # for testing only...
  end



  def index
    @interactive_theme_maps = ThemeMap.where(is_interactive: true).order("name ASC")
    @theme_maps = ThemeMap.where(is_interactive: false).order("name ASC")
  end



  def show
    @theme_map = ThemeMap.where(slug: params[:id]).includes(:map_layers).first
    @theme_map_json = @theme_map.as_json    # send all the layers
    @theme_map.make_mapfile                 # 
    @geo_json = UserLine.load_geo_json(100) # returns 'none' if no user_lines
    # render js: @theme_map
  end
 
# i'm very much like a duck, now, I let it fall off my back. but i'm just like...omg!... katie was awesome...kelly ross
# 

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
    @theme_map.to_param
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
    @theme_map = ThemeMap.where(:slug => params[:id]).first
    @current_neighbor_id = 44                   # current_user.neighbor_id
    @geo_json = UserLine.load_geo_json(100)     # id of interactive layer
    render :js => "featureSource.clear(); geoJson = #{@geo_json}; featureSource.addFeatures(gjFormat.readFeatures(geoJson,
      { dataProjection: 'EPSG:3857'})); alert('reverted');"
  end



  def delete_feature
    id = params[:feature_id].to_i
    feature = UserLine.find(id)
    feature.destroy
    render :js => 'console.log("feature deleted");'
  end



  # update_geo_db should load existing lines or
  # should create new lines and give them id's
  # should delete user-deleted lines (absent from json, or empty json geometry?)
  # TODO implement properties: changed, deleted, only update user_lines that change
  # TODO decide if user_features (point, line or polygon) can replace user_lines

  def update_geo_db
    json = JSON.parse params[:features]
    @theme_map = ThemeMap.find(params[:theme_map][:id])
    gjson = RGeo::GeoJSON.decode( json, json_parser: :json )
    gjson.each do |feature|
      line = nil
      f_id = feature.properties["id"]
      if f_id != nil
        line = UserLine.find(f_id)
      else
        line = UserLine.new
      end
      line.text        = feature.properties["text"]
      line.number      = feature.properties["number"]
      line.amount      = feature.properties["amount"]
      line.name        = feature.properties["name"]
      line.user_id     = @current_user_id
      line.map_layer_id = 100    # @theme_map.interactive_layer_id
      wkt_string  = feature.geometry.as_text
      g_factory = RGeo::Cartesian::Factory.new(srid: 3857)
      line.geometry = g_factory.parse_wkt(wkt_string)
      line.save                  # update_attributes(user_line_params)
    end
    render :js => 'alert("saved");'
  end


  def update
    @theme_map = ThemeMap.where(slug: params[:id]).first
    map_layers = params[:theme_map][:layer_ids]
    base_layers = params[:theme_map][:base_layer_ids]
    # @theme_map.update_layers(map_layers, base_layers)
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
    params.require(:theme_map).permit(:id, :name, :description, :slug, :is_interactive, :thumbnail_url, :layer_ids=>[],
                        :base_layer_ids=>[],  
                        :user_lines_attributes => [:id, :name, :geometry, :text, :number,
                           :amount, :map_layer_id, :user_id], 
                        :theme_map_layers_attributes => [:title, :map_layer_id, :id, 
                           :_destroy, :is_base_layer, :opacity, :layer_type, :draw_order, :visible ]
    )
  end



end
