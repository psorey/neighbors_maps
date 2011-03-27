#!/usr/bin/env ruby
<%= link_to "List Neighbors by Block ID", :controller => 'neighbors', :action => :index,
             :params=>{:select_by => {:item_type => 'half_block_id', :item_list => [385, 482]}}%>
             
 NO:            
 <%= link_to "List Neighbors by Block ID", :controller => 'neighbors', :action => :index,
             :params=>{:select_by => {:item_type => 'half_block_id', :item_list => @my_item_list}}%>