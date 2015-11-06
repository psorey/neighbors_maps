
$( document ).ready(function() {
     $("select").each(function() { this.selectedIndex = 0 });
});

var overlayLayers = [];
var baseLayers = [];

// if interactive
// begin setup of overlay drawing and editing...
var features = new ol.Collection();
var featureSource = new ol.source.Vector({features:features});
var labels = new ol.Collection();
var labelSource = new ol.source.Vector({features:labels});

var gs_team_study_areas;
var gs_team_study_areas_labels;

// why is circle black?
var fill = new ol.style.Fill({
  color: 'rgba(.9,.9,.1,.9)'
});


var stroke = new ol.style.Stroke({
  color: 'rgba(0,0,0,0.6)',
  width: 2
});

var lightStroke = new ol.style.Stroke({
  color: 'rgba(1,1,1,0.6)',
  width: 2
});

var styleCache = {};

// the style function returns an array
function labelStyleFunction(feature, resolution) {
  myStyle = new ol.style.Style({
    fill: fill,
    stroke: stroke,
    image: circleStyle,
    text: new ol.style.Text({
      textAlign: "Start",
      textBaseline: "Middle",
      font: 'Normal 12px Arial',
      text: feature.get('times_per_month'),
      fill: fill,
      stroke: lightStroke,
      offsetX: -3,
      offsetY: 5,
      rotation: 0
      })
    })
  return[myStyle];
};

// todo: dot needs to hide line
var circleStyle = new ol.style.Circle({
  radius: 8,
  fill: fill,
  stroke: stroke,
});


var vectorStyle = new ol.style.Style({
  fill: fill,
  stroke: stroke,
  image: circleStyle
});


var baseLayers;   // need JSON objects:  {"type":"Tile", "title":"watercolor", "base":true, "opacity": .4, "sourceType":"Stamen", "sourceLayer":"watercolor","visible":true, "sourceUrl":"", 
var overlayLayers;
var interactiveLayers;

var numBaseLayers = 3;  // numBaseLayers = 

for(i=0; i < numBaseLayers; i++) {
 // lay = new ol.layer.
}


// todo: load layer data from theme_map, theme_map_layer, and map_layer JSON
// todo: property from theme_map [overrides theme_map_layer?] overrides map_layer properties

var map = new ol.Map({
        target: 'map',
        layers: [  /*
            new ol.layer.Group({
                'title': 'base maps',
                layers: [
                    new ol.layer.Tile({
                        title: 'watercolor',
                        type: 'base',
                        visible: true,
                        opacity: .4,
                        source: new ol.source.Stamen({ layer: 'watercolor' })
                    }),
                    new ol.layer.Tile({
                        title: 'openStreetMap',
                        type: 'base',
                        visible: false,
                        source: new ol.source.OSM()
                    }),
                    new ol.layer.Tile({
                        title: 'satellite',
                        type: 'base',
                        visible: false,
                        source: new ol.source.MapQuest({layer: 'sat'})
                        }),
                    new ol.layer.Image({
                        title: 'greenwood aerial',
                        type: 'base',
                        visible: false,
                        source: new ol.source.ImageWMS({
                           url: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
                           params: {'LAYERS': 'greenwood_aerial', 'VERSION': '1.1.1', 'SRS':'EPSG:3875' },
                           serverType: 'mapserver'
                        })})  
                ]
            }),  */


            new ol.layer.Group({
                title: 'overlays',
                layers: [
                    new ol.layer.Image({
                        title: 'study blocks',
                        source: new ol.source.ImageWMS({
                           url: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
                           params: {'LAYERS': 'study_blocks', 'VERSION': '1.1.1', 'SRS':'EPSG:3875' },
                           serverType: 'mapserver'
                        })}),
                    new ol.layer.Image({
                        title: 'study character',
                        source: new ol.source.ImageWMS({
                           url: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
                           params: {'LAYERS': 'study_character', 'VERSION': '1.1.1', 'SRS':'EPSG:3875' },
                           serverType: 'mapserver'
                        })}),
                    new ol.layer.Image({
                        title: 'study corridors',
                        source: new ol.source.ImageWMS({
                           url: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
                           params: {'LAYERS': 'study_corridors', 'VERSION': '1.1.1', 'SRS':'EPSG:3875' },
                           serverType: 'mapserver'
                        })}),
                  new ol.layer.Image({
                      title: 'neighbors',
                      source: new ol.source.ImageWMS({
                         url: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
                         params: {'LAYERS': 'neighbors', 'VERSION': '1.1.1', 'SRS':'EPSG:3875' },
                         serverType: 'mapserver'
                      })}),
                   new ol.layer.Image({
                        title: 'project boundary',
                        source: new ol.source.ImageWMS({
                           url: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
                           params: {'LAYERS': 'project_boundary', 'VERSION': '1.1.1', 'SRS':'EPSG:3875' },
                           serverType: 'mapserver'
                        })}),
  //                 new ol.layer.Image({
  //                      title: 'half-blocks',
  //                      source: new ol.source.ImageWMS({
  //                         url: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
  //                         params: {'LAYERS': 'half_blocks', 'VERSION': '1.1.1', 'SRS':'EPSG:3875' },
  //                         serverType: 'mapserver'
  //                      })}),
  //                 new ol.layer.Image({
  //                      title: 'p-patches',
  //                      source: new ol.source.ImageWMS({
  //                         url: 'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
  //                         params: {'LAYERS': 'p-patches', 'VERSION': '1.1.1', 'SRS':'EPSG:3875' },
  //                         serverType: 'mapserver'
  //                         })}),


                  // begin setup of overlay drawing and editing...

                  gs_team_study_areas = new ol.layer.Vector({
                      title: "user-drawn lines",  // /var featureOverlay = new ol.layer.Vector({
                      source: featureSource,
                      style: vectorStyle
                  }),

                  gs_team_study_areas_labels = new ol.layer.Vector({
                      title: "user labels",
                      source: labelSource,
                      style: labelStyleFunction // dotStyle
                  })
                ]
            })
        ],
        view: new ol.View({
            // center: ol.proj.transform([-0.92, 52.96], 'EPSG:4326', 'EPSG:3857'),
            center: [-13620870.52201, 6056409.356303 ],
            zoom: 14
        })
    });

    var layerSwitcher = new ol.control.LayerSwitcher({
        tipLabel: 'layer controls'   // Optional label for button
    });

    map.addControl(layerSwitcher);
    var scaleControl = new ol.control.ScaleLine();
    map.addControl(scaleControl);

    /////////////////////////////////////////  interactive ///////////////////////////////


    var prompt_title = 'enter a number';               // @theme_map.prompt_title
    var prompt_string = 'estimated trips per month';   // @theme_map.prompt_string


   featureSource.on('change', function() {
       makeLabeledDots(gs_team_study_areas, gs_team_study_areas_labels);
       console.log("change feature");
    });


    var gjFormat = new ol.format.GeoJSON();


    // store all data in LineString feature; data generates labeled dot on separate 'label' layer
    featureSource.addFeatures(gjFormat.readFeatures({
      "type": "FeatureCollection",
        "features": [{
           "type": "Feature",
           "geometry": { "type": "LineString",
             "coordinates": [[-13621522.730645318, 6055608.910350661],[ -13621083.217732677, 6055284.052980449],[ -13620165.973393254, 6055312.7168660555], [-13619841.116023043, 6055112.069666808],[ -13619119.496548858, 6055252.217636055]]
           },
           "properties": {
             "name": "my_path_1",
             "content": "This is where I like to go when I take a walk.",
             "times_per_month":"5"
           }
         },
         {
           "type": "Feature",
             "geometry": { "type": "LineString",
             "coordinates": [[-13621589.613045067, 6056440.163033262],[ -13621446.29361703, 6056745.911146402], [ -13619602.250309652, 6056487.936175941],[ -13619153.182768477, 6056573.927832761]]
           },
           "properties": {
             "name": "my_path_2",
             "content": "walking to grocery store",
             "times_per_month":"2"
           }
         }
        ]}
    ));


    var my_features = featureSource.getFeatures();
//    for(i=0; i<my_features.length; i++) {
//      my_features[i].getGeometry().transform("EPSG:4326","EPSG:3857");
//    }


    var modify = new ol.interaction.Modify({
      features: features,
      // the SHIFT key must be pressed to delete vertices
      deleteCondition: function(event) {
        return ol.events.condition.shiftKeyOnly(event) &&
          ol.events.condition.singleClick(event);
        }
      });
      map.addInteraction(modify);


      var draw;
      function addInteraction() {
        draw = new ol.interaction.Draw({
          features: features,
          type: (typeSelect.value)
       });
       map.addInteraction(draw);
     }


      var typeSelect = document.getElementById('type');
        typeSelect.onchange = function(e) {
          map.removeInteraction(draw);
       addInteraction();
      };


    // create array of circles and labels
    function makeLabeledDots(geom_layer, label_layer) {
        my_source = geom_layer.getSource();
        lineFeatures = my_source.getFeatures();
        label_source = label_layer.getSource();
        label_source.clear();
        for (var i = 0; i < lineFeatures.length; i++) {
          if (lineFeatures[i] != null) {
            var geometry = lineFeatures[i].getGeometry();
            coords = geometry.flatCoordinates;
            len = coords.length;
            pointCoords = [coords[len-2], coords[len-1]];
            pointFeature = new ol.Feature({
               geometry: new ol.geom.Point(pointCoords)
            });
            pointFeature.set("times_per_month", lineFeatures[i].get("times_per_month"));
            labelSource.addFeature(pointFeature);
          }
        }
        myFeatures = featureSource.getFeatures();
        console.log(gjFormat.writeFeatures(myFeatures));
    }



  function getFeaturesJSON(){
    return gjFormat.writeFeatures(featureSource.getFeatures());
  }


  function showHelp(){
    win = new Window('1', {className: "alphacube", title: 'GS Team Study Areas',
        width:340, height:450, top:70, left:100, zIndex:1500,
        destroyOnClose: true });
    win.setAjaxContent("/theme_maps/gs-team-study-areas/send_help",{id: 'GS Team Study Areas'});
    win.show();
  }


  function revertSaved(){ // returns javascript to refresh the interactive layers...
    console.log("revert saved");
    emptyFeatures();
    new Ajax.Request("/theme_maps/gs-team-study-areas/revert_geo_db", {
      parameters: {
        id: 'gs-team-study-areas'
      },
    });
  }





  $(document).ready(function(){


$('#update_geo_db').on('click', 'a', function() {
  console.log("update_geo_db_ajax");
  $.ajax({
    url: "/theme_maps/gs-team-study-areas/update_geo_db",
    parameters: {
      id: 'gs-team-study-areas',
      contentType: 'text/javascript',
      features: getFeaturesJSON()
    }
  }).done(function() {
    $( this ).addClass( "done" );
  });
})

});

/*
  // Handler for .ready() called.
  $(#update_geo_db).
  function saveChanges(){ // saves the current state of the interactive layers...
    console.log("saveChanges");
    new Ajax.Request("/theme_maps/gs-team-study-areas/update_geo_db", {
      parameters: {
        id: 'gs-team-study-areas',
        contentType: 'text/javascript',
        features: gjFormat.writeFeatures(featureSource.getFeatures())
      },
      onSuccess: function(){
        $("indicator").show();
        $("indicator").fade({ duration: 5.0 });
      }
      //onFailure: showError
    });
  }

});




  function emptyFeatures(){
        gs_team_study_areas.source.clear();
        gs_team_study_areas_labels.source.clear();
        exist_geometries = [];
        exist_labels = [];
        exist_features = [];
      }


      function buildFeatures(){
        console.log("buildfeatures() exist_geometries = ", exist_geometries);
        if (exist_geometries[0] == 'none found' || exist_geometries == 'none found') {
            console.log("no features found");
            exist_geometries = []; // it will hold any geometry that we enter via mouse clicks
            exist_labels = [];
            return;
        }
        geometries = [];
        geometry_labels = [];
        for(i=0; i < exist_geometries.length; i++) {
          // var geom = new ol.format.WKT.readFeatures(unescape(exist_geometries[i]));
          var geom = new ol.Geometry.fromWKT(unescape(exist_geometries[i]));
          console.log("geom= ", geom);
          feature = new ol.Feature.Vector(geom, {geometry_feature_attribute: exist_labels[i]});
          exist_features[i] = feature;
        }
        // triggers the makeLabeledDots function through the 'featuresadded' event callback
        gs_team_study_areas.addFeatures(exist_features);
      }
*/
