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
	if params['q']['year'].blank?
		if Date.current >= Date.current.strftime('%Y-12-16').to_date
			params['q']['year'] = Date.current.year + 1
		else
			params['q']['year'] = Date.current.year
		end	
	end
	if params['as'] == 'column_chart'
		params['q']['sales_date_gteq_datetime'] = "#{params['q']['year'].to_i-1}-12-16".to_date
		params['q']['sales_date_lteq_datetime'] = params['q']['sales_date_gteq_datetime'] + 1.year - 1.day
	else
		if params['q']['month'].blank?
			params['q']['month'] = Date::MONTHNAMES[Date.current.month]
		end
		month = params['q']['month'].to_date.month
		params['q']['sales_date_gteq_datetime'] = "#{params['q']['year']}-#{month}-1".to_date
		params['q']['sales_date_lteq_datetime'] = params['q']['sales_date_gteq_datetime'] + 1.month - 1.day
	end
	if params['q']['sales_status_in'].nil?
		params['q']['sales_status_in'] = ["Booked","Done"]
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
	column :total_sales, sortable: :total_sales do |t|
		link_to pluralize(t.total_sales, 'sale'), sales_path(q: {salevalues_user_id_in: t.leader.id, year: params['q']['year'], month: params['q']['month']})
	end
end

index title: 'Sales Performance Barchart', as: :barchart, class: 'index_as_barchart' do
	@sales = teams.per(teams.length * teams.total_pages).order('SUM(salevalues.nett_value) DESC').sum('salevalues.nett_value')
	@sales = @sales.map { |k,v| [k[0],v]}
	@sales = @sales.to_h.sort_by{|k, v| v}.reverse
	render partial: 'teams/ren_sales_performance', :locals => {sales: @sales, filters: params['q']}, layout: 'layouts/chart'
	a id: 'download_link', download: "barchart-#{Date.current}"
end

index title: 'Monthly Sales Performance', as: :column_chart, class: 'index_as_column_chart' do
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
	render partial: 'teams/monthly_performance', :locals => {sales: @sales}, layout: 'layouts/chart'
	a id: 'download_link', download: "column_chart-#{Date.current}"
end

filter :upline_eq, as: :select, label: 'Upline', :collection => proc { User.approved.accessible_by(current_ability).order(:prefered_name).map { |u| [u.prefered_name, "[#{u.id}]"] } }
filter :main_team, label: 'Team',as: :select, collection: proc { Team.includes(:leader).where(overriding: true) }, input_html: {multiple: true}
filter :year, as: :select, :collection => proc { ((Sale.order('date asc').first.date.year-1)..Date.current.year+1).to_a.reverse }
filter :month, as: :select, :collection => proc { (1..12).to_a.map{|m| Date::MONTHNAMES[m] }}, if: proc {params['as'] != 'column_chart'}
# filter :sales_date, as: :date_range, if: proc {params['as'] != 'column_chart'}
filter :sales_status, as: :select, collection: Sale.status.options, input_html: {multiple: true}
filter :leader_location, as: :select, label: 'REN Location', :collection => User.location.options, input_html: {multiple: true}
filter :projects, input_html: {multiple: true}
filter :leader, label: 'REN', input_html: {multiple: true}

show do
	attributes_table do
		row :name
		row :leader
		row 'Parent Team' do |t|
			t.parent
		end
		row :overriding do |t|
			t.positions.last.overriding
		end
		row :overriding_percentage do |t|
			t.positions.last.overriding_percentage
		end
	end

    # panel "Downlines" do
    #   table_for team.descendants.where(overriding: true).includes(:leader) do
    #     column :name
    #     column :leader
    #     column '' do |team|
    #     	link_to 'Edit', edit_team_path(team), target: '_blank'
    #     end
    #   end
    # end

    # panel 'Organization Chart' do
    # 	teams = team.subtree.joins(:leader).map {|t|
    # 		next if t.leader.nil?
    # 		[t.leader&.prefered_name, t.parent&.leader&.prefered_name]
    # 	}
    # 	render partial: 'teams/org_chart', :locals => {teams: teams.to_json}
    # end
end

form do |f|
	f.semantic_errors *f.object.errors.keys
	inputs do
		input :name
		# input :leader
		# input :overriding_percentage
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
