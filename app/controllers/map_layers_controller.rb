class MapLayersController < ApplicationController


 # layout 'theme_maps'


  def index
    @map_layers = MapLayer.order('name ASC')
  end


  def show
    @map_layer = MapLayer.find(params[:id])
  end


  def new
    @map_layer = MapLayer.new
  end


  def edit
    @map_layer = MapLayer.find(params[:id])
  end


  def create
    @map_layer = MapLayer.new(map_layers_params)
      if @map_layer.save
        redirect_to(@map_layer, :notice => 'MapLayer was successfully created.')
      else
        render "new"
      end
  end


  def update
    @map_layer = MapLayer.find(params[:id])
      if @map_layer.update_attributes(map_layers_params)
        redirect_to(@map_layer, notice: 'MapLayer was successfully updated.')
      else
        render "edit"
      end
  end

  def destroy
    @map_layer = MapLayer.find(params[:id])
    @map_layer.destroy
    redirect_to(map_layers_url)
  end


  private


  def map_layers_params
    params.require(:map_layer).permit(:name, :description, :layer_mapfile_text, :draw_order)
  end


end
