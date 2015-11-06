/*
  function showHelp(){
    win = new Window('1', {className: "alphacube", title: '<%=@theme_map.name %>',
        width:340, height:450, top:70, left:100, zIndex:1500,
        destroyOnClose: true });
    win.setAjaxContent("/theme_maps/<%=@theme_map.slug%>/send_help",{id: '<%=@theme_map.name %>'});
    win.show();
  }


  function revertSaved(){ // returns javascript to refresh the interactive layers...
    emptyFeatures();
    new Ajax.Request("/theme_maps/<%=@theme_map.slug%>/revert_geo_db", {
      parameters: {
        id: '<%=@theme_map.slug%>'
      },
    });
  }
  
  function saveChanges(){ // saves the current state of the interactive layers...
    new Ajax.Request("/theme_maps/<%=@theme_map.slug%>/update_geo_db", {
      parameters: {
        id: '<%=@theme_map.slug%>',
        contentType: 'text/javascript',
        labels: geometry_labels.toSource(),
        geometries: geometries.toSource()
      },
      onSuccess: function(){
        $("indicator").show();
        $("indicator").fade({ duration: 5.0 });
         }
      //onFailure: showError
    });
  }

*/
