#!/usr/bin/env ruby

 <p id="add_link"><%= link_to_function("Add a Subject",
       "Element.remove('add_link'); Element.show('add_subject')")%></p>

<div id="add_subject" style="display:none;">
<%= form_remote_tag(:url => {:action => 'create'}, :update => "subject_list", :position => :bottom, :html => {:id => 'subject_form'})%>
Name: <%= text_field "subject", "name" %>
<%= submit_tag 'Add' %>
<%= end_form_tag %>
</div>

