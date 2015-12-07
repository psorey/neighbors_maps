class ThemeMapLayersController < ApplicationController

  
  def index
    @theme_map_layers = ThemeMapLayer.order('theme_map_id ASC').order('draw_order ASC')
  end


  def show
    @theme_map_layer = ThemeMapLayer.find(params[:id])
  end


  def new
    @theme_map_layer = ThemeMapLayer.new
  end


  def edit
    @theme_map_layer = ThemeMapLayer.find(params[:id])
  end


  def create
    @theme_map_layer = ThemeMapLayer.new(theme_map_layer_params)
    if @theme_map_layer.save
      redirect_to(theme_map_layers_path, notice: 'ThemeMapLayer was successfully created.')
    else
      render "new"
    end
  end


  def update
    @theme_map_layer = ThemeMapLayer.find(params[:id])
    if @theme_map_layer.update_attributes(theme_map_layer_params)
      redirect_to(theme_map_layers_path, notice: 'ThemeMapLayer was successfully updated.')
    else
      render "edit"
    end
  end


  def destroy
    @theme_map_layer = ThemeMapLayer.find(params[:id])
    @theme_map_layer.destroy
    redirect_to(theme_map_layers_url)
  end


private

  def theme_map_layer_params
    params.require(:theme_map_layer).permit(:name, :theme_map_id, :map_layer_id, :is_interactive, :is_base_layer, :draw_order,
                                            :visible, :layer_type, :line_color, :line_width, :fill_color, :opacity)
  end

end
