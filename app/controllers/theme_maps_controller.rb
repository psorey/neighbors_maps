
class ThemeMapsController < ApplicationController
  
  def index
    @theme_maps = ThemeMap.all
  end


  def show
    @theme_map = ThemeMap.find_by_slug(params[:id])
    # build the map_object and write it to a mapfile for Mapserver
    @theme_map.make_mapfile
    
    if @theme_map.is_interactive
      # @current_neighbor_id = current_user.neighbor_id  !!!
      @current_neighbor_id = '44'
      
      existing_mapped_lines = MappedLine.find(:all,
              :conditions => {:owner_id => @current_neighbor_id.to_s, :map_layer_id => @theme_map.name.dashed})
    # back to erasing and re-filling the database with the lines each time...
    # sending just the relevant information via JSON,
    # not the whole mapped_line object which may grow
      geometry_list  = []
      end_label_list = []
      existing_mapped_lines.each do |mapped_line|
        geometry_list       << mapped_line.geometry.as_wkt()
        end_label_list      << mapped_line.end_label
      end
      @json_geometries = geometry_list.to_json
      @json_labels = end_label_list.to_json    
    end
  end


  def new
    @theme_map = ThemeMap.new
    @map_layers = MapLayer.find(:all, :order => 'name')
  end


  def create
    @theme_map = ThemeMap.new(params[:theme_map])
    if !@theme_map.save
      @map_layers = MapLayer.find(:all, :order => 'name')      
      render :action => "new" and return
    end
    map_layers = params[:theme_map][:layer_ids]
    base_layers = params[:theme_map][:base_layer_ids]
    @theme_map.update_layers(map_layers, base_layers)
    if @theme_map.save
      redirect_to(@theme_map, :notice => 'ThemeMap was successfully created.') 
    else
      render :action => "new" 
    end
  end
  

  def edit
    @theme_map = ThemeMap.find_by_slug(params[:id])
    @theme_layer_ids, @base_layer_ids = @theme_map.get_theme_layers
    @map_layers = MapLayer.find(:all, :order => 'name')
    @theme_map.make_mapfile
    
    if @theme_map.is_interactive
      # @current_neighbor_id = current_user.neighbor_id  !!!
      @current_neighbor_id = '44'
      existing_mapped_lines = MappedLine.find(:all,
              :conditions => {:owner_id => @current_neighbor_id.to_s, :map_layer_id => @theme_map.name.dashed})
    # back to erasing and re-filling the database with the lines each time...
    # sending just the relevant information via JSON,
    # not the whole mapped_line object which may grow
      geometry_list  = []
      end_label_list = []
      existing_mapped_lines.each do |mapped_line|
        geometry_list       << mapped_line.geometry.as_wkt()
        end_label_list      << mapped_line.end_label
      end
      @json_geometries = geometry_list.to_json
      @json_labels = end_label_list.to_json    
    end      
  end

  def update_geo_db
      @theme_map = ThemeMap.find_by_slug((params[:id]).gsub('_','-'))
      @current_neighbor_id = '44'  # !!!
      geometries = params[:geometries]
      labels = params[:labels]
    
      logger.debug "LABELS before: #{labels.inspect}"
      geometries.gsub!('"[', '[')
      geometries.gsub!(']"', ']')
      geometries.gsub!('\\', '')
      labels.gsub!('"[', '[')
      labels.gsub!(']"', ']')
      labels.gsub!('\\', '')
      logger.debug "LABELS after: #{labels.inspect}"

      labels_array = JSON.parse(labels)      
      geometries_array = JSON.parse(geometries)  
      MappedLine.destroy_all(:owner_id => @current_neighbor_id, :map_layer_id => @theme_map.name.dashed)
      result = 'successfully saved...'
      for i in 0...geometries_array.length
        if labels_array[i] == nil
          #do nothing
        else
          mapped_line = MappedLine.new
          mapped_line.geometry = Geometry.from_ewkt(geometries_array[i])
          mapped_line.geometry.srid = 4326
          mapped_line.end_label = labels_array[i]
          #mapped_line.owner_id = @current_neighbor_id
          mapped_line.owner_id = '44' # !!!
          mapped_line.map_layer_id = @theme_map.name.dashed
          if !mapped_line.save
            result = 'save failed'
          end
        end
      end
    render :text => result
  end
	

# If you are using Ubuntu 10.04 or Debian and you serve .json files through Apache,
# you might want to serve the files with the correct content type. I am doing this primarily because
# I want to use the Firefox extension JSONView
#
# The Apache module mod_mime will help to do this easily. However, with Ubuntu you need to edit the
# file /etc/mime.types and add the line
# application/json json

  def update
    @theme_map = ThemeMap.find_by_slug(params[:id])
    map_layers = params[:theme_map][:layer_ids]
    base_layers = params[:theme_map][:base_layer_ids]
    @theme_map.update_layers(map_layers, base_layers)
    @theme_map.save
    
    if @theme_map.is_interactive

    end
    if @theme_map.update_attributes(params[:theme_map])
      redirect_to(@theme_map, :notice => 'ThemeMap was successfully updated.')
    else
       render :action => "edit"
    end
  end


  def destroy
    @theme_map = ThemeMap.find_by_slug(params[:id])
    MappedLine.destroy_all(:map_layer_id => @theme_map.name.slug)    
    @theme_map.destroy
    redirect_to(theme_maps_url) 
  end
  
end
