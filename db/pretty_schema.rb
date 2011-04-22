#! /usr/bin/ruby
# strip schema out of schema.rb

def print_general
%q{

Each piece of user-modifiable data has access privileges attached to it.

The 'state' of the piece of data is writable through the set_state() method defined
in the model for each data type. So, for example, when a worker hits the 'submit to 
accounting' button, set_state('submitted') is called on each timesheet entry
submitted.

DATABASE naming conventions for COLUMNS:

'qb_'    one-to-one relationship to Quickbooks data, qb_list_id, qb_full_name, etc.
'cc_'    client_company data, such as cc_name (client company name) cc_id (client company id)


AUTHENTICATION:
All passwords are encrypted, so we have no means of restoring passwords, 
   other than sending them an email with a link to create_new_password_controller.
   
  enforce:
     NO ONE can access cc_admin data without a password from the client company.
     NO ONE except cc_admins can assign themselves any user_type above 'worker'. 
     Only cc_admins can assign anyone higher level access to their company data. 
     Only oo_admins can assign cc_admin status to anyone.   
}


end





def print_table_info(table_name)
  case table_name
  when 'users'
    puts "Note that password is encrypted."
    puts "Users can have roles as several different workers."
    puts "Users have roles through workers."
    puts "Users can take on one role at one client company at one time."
    puts "User is created edited and destroyed by the user."
    puts "User can belong to several workers"
    puts "Users become workers by invitation from a client company."
    puts "Users' roles can be: 'guests', 'workers' for client companies, 'accountants' for cc's,"
    puts "   'administrators' for cc's, zebratime administrators, zebratime accountants."
    
  when 'workers'
  	puts "workers belong to client_companies"
    puts "each worker has only one role"
    puts "there could be more than one worker at a client_company"
    puts "      with the same user name but having different roles."
	
  when 'jobs'
		puts 'company, company:job, company:job:subjob, etc...'
		puts "needed: ability to configure the format for each company "
		
	when 'client_companies'
		puts "needed: a separate table (or database) of client company accounts"
		puts "  and billing for our bookkeeping"
  
	when 'roles'
    puts "guest, worker, pm, accountant, administrator, ztadmin, ztaccounting"
	
  when 'qb_payroll_items'


	when 'qb_service_items'


	when 'qbwc_sessions'
    puts "associates a 'token' with a cc_id, has a COPY of the client_company's request queue"
    puts "that shifts left for each request completed, and keeps track of percentage completed"

	when 'qbwc_tasks'
		puts "cc_id defaults to 'ALL'"
		puts "pre-defined set of tasks, pre-loaded into database:"
		puts "   rq_company         refresh company info "
		puts "   rq_jobs            refresh jobs "
		puts "   rq_employees       refresh employees"
		puts "   rq_vendors         refresh vendors"
		puts "   rq_payroll_items   refresh payroll items"
		puts "   rq_service_items   refresh service items "
		puts "   rq_classes         refresh classes"
		puts "   add_time           get timesheets (within dates specified) "
  
	when 'ts_entry_states'
		puts "pre-defined set of states, pre-loaded into database:"
		puts "   _entered_by_worker      # entered, but still editable by worker"
    puts "   _pending_pm_approval    # check job for pm approval requirements "
    puts "   _flagged_by_pm          # pm sends back to worker for change" 
    puts "   _flagged_by_acct        # acct sends back to worker for change"
    puts "   _pending_acct_approval  # after worker submits (if pm approval not needed)"
    puts "   _quickbooks_ready       # to be uploaded"
    puts "   _quickbooked            # uploaded"
    
	when 'ts_entries'
		puts "note that a worker could be an employee or service vendor..."
  end
  
end



f = File.open "schema.rb"
f.each_line do |line|

  if line["create_table"]
    line =~ /".*"/
    table_name = $&
    table_name.gsub!(/"/,'')
    puts "\n\n\n#{table_name.upcase}\n"
    print_table_info(table_name)
    puts ""
    puts sprintf("%1$*3$s %2$*3$s", "id", "integer", -30)
  elsif line["t."]
    data_type = line.split[0]
    type = (data_type.split '.')[1]
    
    line =~ /".*"/
    column_name = $&
    column_name.gsub!(/"/,'')
    column_name.gsub!(/,/,'')
    col = column_name.split[0]
    puts sprintf("%1$*3$s %2$*3$s", col, type, -30)
    
  end
  

end
  puts print_general
