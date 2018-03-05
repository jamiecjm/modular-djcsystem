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

menu priority: 1, parent: 'Teams', label: 'Performance'

includes :leader, main_team: :leader

permit_params :name, :leader_id, :overriding, :overriding_percentage

controller do
    def scoped_collection
    	if params['action'] == 'index'
	    	if params['as'].blank?
			  	end_of_association_chain.group('leader_id', 'users.prefered_name', 'teams.id').select('SUM(salevalues.spa) as total_spa_value', 'SUM(salevalues.nett_value) as total_nett_value', 
					'SUM(salevalues.comm) as total_comm', 'COUNT(salevalues.id) as total_sales', :leader_id)
			elsif params['as'] == 'barchart'
				end_of_association_chain.group('users.prefered_name', 'teams.id')
			else
				end_of_association_chain
			end
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
		if params['q']['year'].nil?
			params['q']['year'] = Date.current.year
		end
		year = params['q']['year']
		params['q']['sales_date_gteq_datetime'] = "#{year.to_i-1}-12-16"
		params['q']['sales_date_lteq_datetime'] = "#{year}-12-15"
	else
		if params['q']['year'].nil?
			if params['q']['sales_date_gteq_datetime'].nil?
				params['q']['sales_date_gteq_datetime'] = Date.current.beginning_of_month
			end
			if params['q']['sales_date_lteq_datetime'].nil?
				params['q']['sales_date_lteq_datetime'] = Date.today
			end		
		else
			year = params['q']['year']
			params['q']['sales_date_gteq_datetime'] = "#{year.to_i-1}-12-16"
			params['q']['sales_date_lteq_datetime'] = "#{year}-12-15"
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

collection_action :download do
	respond_to do |format|
		format.js
	end
end

action_item :download, only: :index, if: proc { params['as']=='barchart' || params['as']=='column_chart' } do
	link_to 'Download', download_teams_path(url: request.fullpath), remote: true
end

batch_action :destroy, false

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

index title: 'Sales Performance Barchart', as: :barchart, class: 'index_as_barchart' do
	div id: 'chart' do
		@sales = teams.per(teams.length * teams.total_pages).order('SUM(salevalues.nett_value) DESC').sum('salevalues.nett_value')
		@sales = @sales.map { |k,v| [k[0],v]}
		@sales = @sales.to_h.sort_by{|k, v| v}.reverse
		div class: 'logo_div' do
			image_tag current_website.logo.url
		end
		render partial: 'admin/charts/ren_sales_performance', :locals => {sales: @sales}
	end
	a id: 'download_link', download: "graph-#{Date.current}"
end

index title: 'Monthly Sales Performance', as: :column_chart, class: 'index_as_column_chart' do
	div id: 'chart' do
		div class: 'logo_div' do
			image_tag current_website.logo.url
		end
		@sales = teams.per(teams.length * teams.total_pages).group('teams.id').group_by_month('sales.date', format: "%B %Y").sum('salevalues.nett_value')
		@sales.to_a.map do |k,v|
			new_key = k[1]
			@sales[new_key] ||= 0
			@sales[new_key] += v
			@sales.delete(k)
		end
		year = params['q']['year'] 
		d1 = params['q']['sales_date_gteq_datetime'].to_date
		d2 = params['q']['sales_date_lteq_datetime'].to_date
		months = (d1..d2).map {|d| [d.strftime('%B %Y'), 0]}.uniq
		@sales = months.to_h.merge!(@sales){|k, old_v, new_v| old_v + new_v}
		render partial: 'admin/charts/monthly_performance', :locals => {sales: @sales}
	end
	a id: 'download_link', download: "graph-#{Date.current}"
end

filter :upline_eq, as: :select, label: 'Upline', :collection => proc { current_user.pseudo_team_members.order('prefered_name').map { |u| [u.prefered_name, "[#{u.id}]"] } }
filter :main_team, label: 'Team',as: :select, collection: proc { Team.includes(:leader).where(overriding: true) }, input_html: {multiple: true}
filter :year, as: :select, :collection => proc { (1900..Date.current.year+1).to_a.reverse }
filter :sales_date, as: :date_range, if: proc {params['as'] != 'column_chart'}
filter :sales_status, as: :select, collection: Sale.statuses.map {|k,v| [k,v]}, input_html: {multiple: true}
filter :leader_location, as: :select, label: 'REN Location', :collection => User.locations.map {|k,v| [k,v]}, input_html: {multiple: true}
filter :projects, input_html: {multiple: true}
filter :leader, label: 'REN', input_html: {multiple: true}

show do
	attributes_table do
		row :name
		row :leader
		row 'Upline Team' do |team|
			team.parent
		end
		row :overriding
		row :overriding_percentage
	end

    panel "Downlines" do
      table_for team.descendants.where(overriding: true).includes(:leader) do
        column :name
        column :leader
        column :overriding
        column :overriding_percentage
        column '' do |team|
        	link_to 'Edit', edit_team_path(team), target: '_blank'
        end
      end
    end
end

form do |f|
	f.semantic_errors *f.object.errors.keys
	inputs do
		input :name
		input :leader
		input :overriding_percentage
	end
	actions
end

csv do
	column(:no) do
		if @no.nil?
			@no = 1
		else
			@no += 1
		end
	end
	column('Name') do |t|
		t.leader.prefered_name
	end
	column('Location') do |t|
		t.leader.location
	end
	column('Team') { |t| t.main_team.display_name }
	column :total_spa_value
	column :total_nett_value
	column :total_comm
	column :total_sales
end

end
