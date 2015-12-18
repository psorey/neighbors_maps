
json.extract! theme_map, :slug, :is_interactive  #  :description json.

json.layers theme_map.theme_map_layers do |tml|
  json.title tml.title
  json.layerType tml.layer_type
  json.isBaseLayer tml.is_base_layer
  json.opacity tml.opacity
  json.visible tml.visible
  json.drawOrder tml.draw_order
  if tml.layer_type == 'Vector'
    json.geojson  VectorFeature::load_geo_json(tml.map_layer_id) 
  end
  json.source do |json|
    json.sourceType tml.map_layer.source_type
    json.sourceLayer tml.map_layer.source_layer
    if tml.map_layer.source_type === 'ImageWMS'
      json.sourceUrl tml.map_layer.source_url
      json.wmsServerType tml.map_layer.source_server_type
    end
    if tml.map_layer.source_type === 'TileJSON'
      json.sourceUrl tml.map_layer.source_url
    end
  end
end

