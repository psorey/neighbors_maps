
# this doesn't work because it doesn't have access to the javascript variables!...

      <%= link_to_remote ("save changes", {
          :url => "/theme_maps/#{@theme_map.name.dashed}/update_geo_db",
          :parameters => {
            :id => "#{@theme_map.name.dashed}",
            :contentType => 'text/javascript',
            :labels => JSON.stringify(geometry_labels),
            :geometries => JSON.stringify(geometries) 
          }
        }) %>
  
# this works....
  <%= button_to_function "save changes", "saveChanges()" %>
  
  function saveChanges(){
    new Ajax.Request("/theme_maps/<%=@theme_map.name.dashed%>/update_geo_db", {
      parameters: {
        id: '<%=@theme_map.name.dashed%>',
        contentType: 'text/javascript',
        labels: JSON.stringify(geometry_labels),
        geometries: JSON.stringify(geometries)
      },
      //onSuccess: showResponse,
      //onFailure: showError
    });
  }