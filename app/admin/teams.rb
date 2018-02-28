ActiveAdmin.register Team do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

menu priority: 0, parent: 'Teams', label: 'Performance'

controller do
    def scoped_collection
    	if params['as'].blank?
		  	end_of_association_chain.group('leader_id', 'users.prefered_name', 'teams.id').select('SUM(salevalues.spa) as total_spa_value', 'SUM(salevalues.nett_value) as total_nett_value', 
				'SUM(salevalues.comm) as total_comm', 'COUNT(salevalues.id) as total_sales', :leader_id)
		elsif params['as'] == 'barchart'
			end_of_association_chain.group('users.prefered_name', 'teams.id')
		else
			end_of_association_chain
		end
    end
end

before_action only: :index do 
	if params['q'].blank?
		params['q'] = {}
	end
	if params['as'] == 'column_chart'
		if params['q']['sales_date_gteq_datetime'].nil?
			if Date.current >= Date.current.strftime('%Y-12-16').to_date
				params['q']['sales_date_gteq_datetime'] = Date.current.strftime('%Y-12-16').to_date
			else
				params['q']['sales_date_gteq_datetime'] = "#{Date.current.year-1}-12-16".to_date
			end
		end
		if params['q']['sales_date_lteq_datetime'].nil?
			if Date.current <= Date.current.strftime('%Y-12-15').to_date
				params['q']['sales_date_lteq_datetime'] = Date.current.strftime('%Y-12-15').to_date
			else
				params['q']['sales_date_lteq_datetime'] = "#{Date.current.year+1}-12-15".to_date
			end
		end
	else
		if params['q']['sales_date_gteq_datetime'].nil?
			params['q']['sales_date_gteq_datetime'] = Date.current.beginning_of_month
		end
		if params['q']['sales_date_lteq_datetime'].nil?
			params['q']['sales_date_lteq_datetime'] = Date.today
		end			
	end
	if params['q']['sales_status_eq'].nil?
		params['q']['sales_status_in'] = [0,1]
	else
		params['q']['sales_status_in'] = nil
	end
	if params['q']['upline_eq'].nil?
		params['q']['upline_eq'] = "[#{current_user.id}]"
	end
	if !params['as'].nil? && params['as'] != 'table'
		params['per_page'] = '1'
		params['order'] = nil
	else
		params['as'] = nil
		params['per_page'] = nil
		if params['order'].nil?
			params['order'] = 'total_nett_value_desc'
		end
	end
end	

index title: 'Sales Performance', default: true do
	column :no do |t|
		if @no.nil?
			@no = 1
		else
			@no += 1
		end
	end
	column 'Name', :leader, sortable: 'users.prefered_name' do |t|
		link_to t.leader.prefered_name, salevalues_path(q: {user_id_eq: t.leader.id}), target: '_blank'
	end
	column 'Location' do |t|
		t.leader.location
	end
	column 'Team', :main_team
	# list_column :projects do |t|
	# 	t.projects.pluck(:name).each_slice(5).to_a
	# end
	number_column :total_spa_value, as: :currency, seperator: ',', unit: '', sortable: :total_spa_value
	number_column :total_nett_value, as: :currency, seperator: ',', unit: '', sortable: :total_nett_value
	number_column :total_comm, as: :currency, seperator: ',', unit: '', sortable: :total_comm
	column :total_sales, sortable: :total_sales
end

index title: 'Sales Performance Barchart', as: :barchart do
	div class: 'graph_div' do
		@sales = teams.per(teams.length * teams.total_pages).order('SUM(salevalues.nett_value) DESC').sum('salevalues.nett_value')
		@sales = @sales.map { |k,v| [k[0],v]}
		@sales = @sales.to_h.sort_by{|k, v| v}.reverse
		div class: 'logo_div' do
			image_tag 'https://res.cloudinary.com/dpog1tvij/image/upload/v1499525286/gtsyyemrtaij33arjmba.png'
		end
		render partial: 'admin/charts/ren_sales_performance', :locals => {sales: @sales}
	end
end

index title: 'Monthly Sales Performance', as: :column_chart do
	div class: 'graph_div' do
		div class: 'logo_div' do
			image_tag 'https://res.cloudinary.com/dpog1tvij/image/upload/v1499525286/gtsyyemrtaij33arjmba.png'
		end
		@sales = teams.per(teams.length * teams.total_pages).group('teams.id').group_by_month('sales.date', format: "%b %Y").sum('salevalues.nett_value')
		@sales.to_a.map do |k,v|
			new_key = k[1]
			@sales[new_key] ||= 0
			@sales[new_key] += v
			@sales.delete(k)
		end
		d1 = params['q']['sales_date_gteq_datetime'].to_date
		d2 = params['q']['sales_date_lteq_datetime'].to_date
		months = (d1..d2).map {|d| [d.strftime('%B %Y'), 0]}.uniq
		@sales.merge!(months.to_h)
		render partial: 'admin/charts/monthly_performance', :locals => {sales: @sales}
	end
end

filter :main_team, label: 'Team',as: :select, collection: proc { Team.where(overriding: true) }
filter :upline_eq, as: :select, label: 'Upline', :collection => proc { User.order('prefered_name').map { |u| [u.prefered_name, "[#{u.id}]"] } }
filter :sales_date, as: :date_range
filter :sales_status, as: :select, collection: Sale.statuses.map {|k,v| [k,v]}
filter :leader_location, as: :select, label: 'REN Location', :collection => User.locations.map {|k,v| [k,v]} 
filter :projects
filter :leader, label: 'REN'

end
