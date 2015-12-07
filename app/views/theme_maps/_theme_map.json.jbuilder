json.extract! theme_map, :slug, :is_interactive  # , :description json.

json.layers theme_map.theme_map_layers do |tml|
  json.name tml.map_layer.name
  json.layerType tml.layer_type
  json.isBaseLayer tml.is_base_layer
  json.opacity tml.opacity
  json.visible tml.visible
  json.drawOrder tml.draw_order
  json.source do |json|
    json.sourceType tml.map_layer.source.source_type
    json.sourceLayer tml.map_layer.source.layer
    if tml.map_layer.source.source_type == 'ImageWMS'
      json.wmsUrl tml.map_layer.source.url
      json.wmsParams tml.map_layer.source.wms_params
      json.wmsServerType tml.map_layer.source.server_type
    end
  end
end


