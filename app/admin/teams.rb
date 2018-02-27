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

scope 'Count', default: true do |teams|
	teams.group('leader_id').select('SUM(salevalues.spa) as total_spa_value', 'SUM(salevalues.nett_value) as total_nett_value', 'SUM(salevalues.comm) as total_comm', 'COUNT(salevalues.id) as total_sales', :leader_id)
end


before_action only: :index do 
	if params['q'].blank?
		params['q'] = {}
	end
	if params['q']['sales_date_gteq_datetime'].blank?
		params['q']['sales_date_gteq_datetime'] = Date.current.beginning_of_month
	end
	if params['q']['sales_date_lteq_datetime'].blank?
		params['q']['sales_date_lteq_datetime'] = Date.today
	end
	if params['order'].blank?
		params['order'] = 'total_nett_value_desc'
	end
	if params['q']['sales_status_eq'].blank?
		params['q']['sales_status_in'] = [0,1]
	else
		params['q']['sales_status_in'] = nil
	end
end	

index title: 'Sales Performance' do
	column :no do |t|
		if @no.nil?
			@no = 1
		else
			@no += 1
		end
	end
	column 'Name', :leader do |t|
		link_to t.leader.prefered_name, salevalues_path(q: {user_id_eq: t.leader.id}), target: '_blank'
	end
	number_column :total_spa_value, as: :currency, seperator: ',', unit: '', sortable: :total_spa_value
	number_column :total_nett_value, as: :currency, seperator: ',', unit: '', sortable: :total_nett_value
	number_column :total_comm, as: :currency, seperator: ',', unit: '', sortable: :total_comm
	column :total_sales, sortable: :total_sales
end

filter :sales_by_upline, as: :select, label: 'Upline', :collection => proc { User.order('prefered_name').map { |u| [u.prefered_name, "[#{u.id}]"] } }
filter :sales_date, as: :date_range
filter :sales_status, as: :select, collection: Sale.statuses.map {|k,v| [k,v]}
filter :projects
filter :leader, label: 'REN'

end
