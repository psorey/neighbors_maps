
    var geometry_labels = [];
    var exist_features = [];
    var exist_geometries = [];
    var exist_labels = [];
    var map, drawControls, walking_paths_survey, walking_paths_survey_labels;

    function init(){
      map = new OpenLayers.Map('map', {maxExtent: new OpenLayers.Bounds(1259300,253000,1269500,263500)});
          ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var parcel_outlines = new OpenLayers.Layer.WMS('Parcel Outlines',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'parcel_outlines',
          format: 'png',
          transparent: 'true'},
        { 
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var parcels = new OpenLayers.Layer.WMS('Parcels',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'parcels',
          format: 'png',
          transparent: 'true'},
        { 
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var parks = new OpenLayers.Layer.WMS('Parks',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'parks',
          format: 'png',
          transparent: 'true'},
        { 
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var project_boundary = new OpenLayers.Layer.WMS('Project Boundary',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'project_boundary',
          format: 'png',
          transparent: 'true'},
        { 
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var street_names = new OpenLayers.Layer.WMS('Street Names',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'street_names',
          format: 'png',
          transparent: 'true'},
        { 
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var study_areas_blocks = new OpenLayers.Layer.WMS('Study Areas Blocks',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'study_areas_blocks',
          format: 'png',
          transparent: 'false'},
        { 
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:true,
          singleTile:true,
        }
      );
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var study_areas_character_ = new OpenLayers.Layer.WMS('Study Areas Character ',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'study_areas_character_',
          format: 'png',
          transparent: 'false'},
        { 
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:true,
          singleTile:true,
        }
      );
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var study_areas_corridors = new OpenLayers.Layer.WMS('Study Areas Corridors',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'study_areas_corridors',
          format: 'png',
          transparent: 'false'},
        { 
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:true,
          singleTile:true,
        }
      );
    ///// begin map_layer //////////////////////////////////////////////////     
    console.log("begin map_layer");  
      var zoning = new OpenLayers.Layer.WMS('Zoning',
      'http://localhost/cgi-bin/mapserv?map=/home/paul/mapserver/gs_team_study_areas.map',
        { layers: 'zoning',
          format: 'png',
          transparent: 'true'},
        { 
          scales: [100,200,300,400,500,600,800,1000,1200,1500,2000,4000,8000,12000,18000,24000,32000,48000,56000],
          units: 'm',
          projection:new OpenLayers.Projection("epsg:4326"),
          gutter:0,
          ratio:1,
          isBaselayer:false,
          singleTile:true,
        }
      );

        
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
 
    }
