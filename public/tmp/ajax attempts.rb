  
  
  <%= link_to 'update_geo_db', "/theme_maps/#{@theme_map.name.dashed}/update_geo_db" %>
  <%= link_to_remote "Check Time",
    :update => 'current_time',
    :url    => "/theme_maps/#{@theme_map.name.dashed}/update_geo_db" %>
  <div id="current_time"></div>
  
      <%= button_to_function "save changes", "saveChanges()" %>
   
   
   
      
  function saveChanges(){
    new Ajax.Request("/theme_maps/<%=@theme_map.name.dashed%>/update_geo_db", {
      // method: 'put',
      parameters: {
        contentType: 'application/json',
        // labels: JSON.stringify(geometry_labels),
        // geometries: JSON.stringify(geometries)
        labels: geometry_labels.to_string(),
        geometries: geometries.to_string()
      }
      //onSuccess: showResponse,
      //onFailure: showError
    });
  }