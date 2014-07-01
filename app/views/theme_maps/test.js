          
        var geometries = [];
        var geometry_labels = [];
        var exist_features = [];
        var exist_geometries = [];
        var exist_labels = [];
        var map, drawControls, gs_team_study_areas, gs_team_study_areas_labels;
          
        $(document).ready(function(){
          console.log("begin open_layers_interactive_functions"); ///// begin open_layers_interactive_functions ////////////////////////////////
          function emptyFeatures(){
            gs_team_study_areas.destroyFeatures();
            gs_team_study_areas_labels.destroyFeatures();
            exist_geometries = [];
            exist_labels = [];
            exist_features = [];
          }

          function buildFeatures(){
            console.log("buildfeatures() exist_geometries = ", exist_geometries);
            if (exist_geometries[0] == 'none found' || exist_geometries == 'none found') {
              console.log(" we must return");
              exist_geometries = []; // it will hold any geometry that we enter via mouse clicks
              exist_labels = [];
              return; 
            }
            geometries = [];
            geometry_labels = [];
            console.log(exist_geometries[0]);
            console.log(exist_geometries[1]);
            console.log(exist_geometries.length);
            for(i=0; i < exist_geometries.length; i = i + 1) { // !!! !!! !!!
              var geom = new OpenLayers.Geometry.fromWKT(unescape(exist_geometries[i]));
              console.log("geom= ", geom);
              feature = new OpenLayers.Feature.Vector(geom, {geometry_feature_attribute: exist_labels[i]});
              exist_features[i] = feature;
             // console.log ("buildFeatures()", feature.geometry.toString());
            }
           // this triggers the makeLabeledDots function through the 'featuresadded' event callback      
           gs_team_study_areas.addFeatures(exist_features);
          }

          function toggleControl(element) {
            element.preventDefault();
            for(key in drawControls) {
              var control = drawControls[key];
              if(element.value == key && element.checked) {
                control.activate();
              } else {
                control.deactivate();
              }
            }
            makeLabeledDots(gs_team_study_areas, gs_team_study_areas_labels);
          }
               
          function makeLabeledDots(geom_layer, label_layer) {
            var lineFeatures = geom_layer.features; //returns: {Array(OpenLayers.Feature.Vector)}               
            //console.log("make labeled dots: lineFeatures--> length =", lineFeatures.length(), lineFeatures );
            label_layer.destroyFeatures();
            geometries = [];
            geometry_labels = [];
            for (var i = 0; i < lineFeatures.length; i = i+1) {       
              if (lineFeatures[i] != null) {                  
                var geometry = lineFeatures[i].geometry;
                var nodes = lineFeatures[i].geometry.getVertices();
                var lastNode = nodes[nodes.length -1];
                var pointFeature = new OpenLayers.Feature.Vector(lastNode);
                var count = i + '';
                pointFeature.attributes = {
                  geometry_feature_attribute: lineFeatures[i].attributes.geometry_feature_attribute, whichLine: count};
                  label_layer.addFeatures(pointFeature);
                  var wktwriter=new OpenLayers.Format.WKT();
                  var wkt=wktwriter.write(lineFeatures[i]);
                  geometries.push(wkt);
                  geometry_labels.push(lineFeatures[i].attributes.geometry_feature_attribute);
              }
            }
          }
          ///// end open_layers_in
          function showHelp(){
            //    win = new Window('1', {className: "alphacube", title: 'GS Team Study Areas',
            //        width:340, height:450, top:70, left:100, zIndex:1500,
            //        destroyOnClose: true });
            //    win.setAjaxContent("/theme_maps/gs-team-study-areas/send_help",{id: 'gs_team_study_areas'});
            //    win.show();
          }
          function revertSaved(){ // returns javascript to refresh the interactive layers...
            //    emptyFeatures();
            //    new Ajax.Request("/theme_maps/gs-team-study-areas/revert_geo_db", {
           //      parameters: {
           //        id: 'gs-team-study-areas'
           //      },
           //    });
          }
          $('#update_geo_db').click(function() {
            console.log("in update_geo_db.click --> ", geometries.toSource(), geometry_labels.toSource());
            var request = $.ajax({
              url: "/theme_maps/gs-team-study-areas/update_geo_db",
              type: "POST",
              data: {geometries: geometries.toSource(), labels: geometry_labels.toSource()},
              dataType: "html"
            });
            request.done(function( msg ) {
              $("#rails_error").text("it says we're done: " + msg);
            });
            request.fail(function( jqXHR, textStatus ) {
              $("#rails_error").text("error: " + jqXHR.responseXML);
            });
          });
          //  onSuccess: function(){
          //    $("indicator").show();
          //    $("indicator").fade({ duration: 5.0 });
          //  }
          map = new OpenLayers.Map('map', {maxExtent: new OpenLayers.Bounds(1259300,253000,1269500,263500)});
          // end of document.ready
        
            ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var parcel_outlines = new OpenLayers.Layer.WMS('Parcel Outlines',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'parcel_outlines',
          format: 'png',
          transparent: 'true'},
        { 
          //scales: [100,200,400,800,1600,3200,6400,12800,25600,51200],
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
     
      ///// end map_layer ////////////////////////////////////////////////// 
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var parcels = new OpenLayers.Layer.WMS('Parcels',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'parcels',
          format: 'png',
          transparent: 'true'},
        { 
          //scales: [100,200,400,800,1600,3200,6400,12800,25600,51200],
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
     
      ///// end map_layer ////////////////////////////////////////////////// 
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var parks = new OpenLayers.Layer.WMS('Parks',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'parks',
          format: 'png',
          transparent: 'true'},
        { 
          //scales: [100,200,400,800,1600,3200,6400,12800,25600,51200],
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
     
      ///// end map_layer ////////////////////////////////////////////////// 
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var project_boundary = new OpenLayers.Layer.WMS('Project Boundary',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'project_boundary',
          format: 'png',
          transparent: 'true'},
        { 
          //scales: [100,200,400,800,1600,3200,6400,12800,25600,51200],
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
     
      ///// end map_layer ////////////////////////////////////////////////// 
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var street_names = new OpenLayers.Layer.WMS('Street Names',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'street_names',
          format: 'png',
          transparent: 'true'},
        { 
          //scales: [100,200,400,800,1600,3200,6400,12800,25600,51200],
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
     
      ///// end map_layer ////////////////////////////////////////////////// 
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var study_areas_blocks = new OpenLayers.Layer.WMS('Study Areas Blocks',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'study_areas_blocks',
          format: 'png',
          transparent: 'false'},
        { 
          //scales: [100,200,400,800,1600,3200,6400,12800,25600,51200],
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:true,
          singleTile:true,
        }
      );
     
      ///// end map_layer ////////////////////////////////////////////////// 
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var study_areas_character_ = new OpenLayers.Layer.WMS('Study Areas Character ',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'study_areas_character_',
          format: 'png',
          transparent: 'false'},
        { 
          //scales: [100,200,400,800,1600,3200,6400,12800,25600,51200],
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:true,
          singleTile:true,
        }
      );
     
      ///// end map_layer ////////////////////////////////////////////////// 
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var study_areas_corridors = new OpenLayers.Layer.WMS('Study Areas Corridors',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'study_areas_corridors',
          format: 'png',
          transparent: 'false'},
        { 
          //scales: [100,200,400,800,1600,3200,6400,12800,25600,51200],
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:true,
          singleTile:true,
        }
      );
     
      ///// end map_layer ////////////////////////////////////////////////// 
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var zoning = new OpenLayers.Layer.WMS('Zoning',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'zoning',
          format: 'png',
          transparent: 'true'},
        { 
          //scales: [100,200,400,800,1600,3200,6400,12800,25600,51200],
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
     
      ///// end map_layer ////////////////////////////////////////////////// 

        
     //// begin open_layers_init ////////////////////////////
     console.log("begin open_layers_init");
      map.addLayers([parcels,zoning,parks,parcel_outlines,project_boundary,study_areas_character_,study_areas_corridors,study_areas_blocks,street_names]);

      map.addControl(new OpenLayers.Control.Scale('scale'));
      map.addControl(new OpenLayers.Control.MousePosition());
      var layerSwitch = new OpenLayers.Control.LayerSwitcher();
      map.addControl(layerSwitch);
      layerSwitch.maximizeControl();
      map.zoomToMaxExtent();      
      
      //// end open_layers_init ////////////////////////////////

     });

