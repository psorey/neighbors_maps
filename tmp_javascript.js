{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [0, 0]
      },
      "properties": {
        "name": "null island"
      }
    }
  ]
}

geoJsonObject
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Multiline",
        "coordinates": [0, 0]
      },
      "properties": {
        "name": "<%=@theme_map_layer.name %>",
        "opacity": <%=@theme_map_layer.opacity %>,
        "server_url": "<%=@theme_map_layer.server_url %>",
        "layer_url": "<%=@theme_map_layer.layer_url %>",
        "srs": "<%=@theme_map_layer.srs %>",
        "is_base_layer": "<%=@theme_map_layer.is_base_layer %>"
      }
    }
  ]
}





// database data params coming from server:
var  wkt_geometry[];
var  name[];
var  opacity[];
var  server_url[];
var  layer_url[];
var  wmsValues[][];
var  srs[];
var  opacity[];
var  isBaseLayer[]; 

new ol.layer.Image

var map;
var num_layers;
var layer_name;
var layer_type;             // POLYGON?  IMAGE
var layer_opacity;  
var layer_order;    
var layer_geometry;         // ol3.Collection
var layer_url;              // 'http://<%=layer_server_url%>/cgi-bin/mapserv?map=/home/paul/mapserver/<%=@theme_map.name.dashed%>.map',
var layer_wms_list;         // 'study_blocks neighbors parcel_outlines'
var layer_wms_version;      // '1.1.1'
var layer_srs;              // 'EPSG:3875'


function MakeLayers() {
  for(i=0; i<numLayers; i++) {
    layer = makeOneLayer(i);
    map.addLayer(layer);'
  }
  
}



function makeOneLayer(i) {

  newLayer = new ol.layer.Image({



var make_layers = (function 
  newLayer = new ol.layer.Image({
	title: '<%=@theme_map.theme_map_layer[i].map_layer %>',
	source: new ol.source.ImageWMS({
	   url: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
	params: {'LAYERS': 'study_blocks', 'VERSION': '1.1.1', 'SRS':'EPSG:3875' },
	serverType: 'mapserver'
	})})
 
