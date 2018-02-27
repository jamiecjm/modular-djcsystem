ActiveAdmin.register Salevalue do
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

menu label: 'Individual', parent: 'Sales'

includes :sale, :project, :commission

scope 'Booked/Done', default: true do |sv|
	sv.not_cancelled
end

scope :cancelled

scope :all

before_action only: :index do 
	if params['q'].blank?
		params['q'] = {}
	end
	if params['q']['user_id_eq'].blank?
		params['q']['user_id_eq'] = current_user.id
	end
	if params['q']['sale_date_gteq_datetime'].blank?
		if Date.current >= Date.current.strftime('%Y-12-16').to_date
			params['q']['sale_date_gteq_datetime'] = Date.current.strftime('%Y-12-16').to_date
		else
			params['q']['sale_date_gteq_datetime'] = "#{Date.current.year-1}-12-16".to_date
		end
	end
	if params['q']['sale_date_lteq_datetime'].blank?
		params['q']['sale_date_lteq_datetime'] = Date.today
	end
end

index title: 'Individual Sales' do
	selectable_column
	column :sale, sortable: 'sales.id'
	column :date, sortable: 'sales.date' do |sv|
		sv.sale.date
	end
	column :status, sortable: 'sales.status' do |sv|
		sv.sale.status
	end
	column :project, sortable: 'projects.name'
	column :unit_no, sortable: 'sales.unit_no' do |sv|
		sv.sale.unit_no
	end
	column :buyer, sortable: 'sales.buyer' do |sv|
		sv.sale.buyer
	end
	column 'REN Sale Percentage', :percentage
	number_column 'REN SPA Value', :spa, as: :currency, seperator: ',', unit: ''
	number_column 'REN Nett Value', :nett_value, as: :currency, seperator: ',', unit: ''
	number_column 'REN Commission', :comm, as: :currency, seperator: ',', unit: ''
	number_column :unit_size, sortable: 'sales.unit_size', as: :currency, seperator: ',', unit: '' do |sv|
		sv.sale.unit_size
	end
	number_column :unit_spa_value, sortable: 'sales.spa_price', as: :currency, seperator: ',', unit: '' do |sv|
		sv.sale.spa_value
	end
	number_column :unit_nett_value, sortable: 'sales.nett_price', as: :currency, seperator: ',', unit: '' do |sv|
		sv.sale.nett_value
	end	
	column 'Project Commission', :commission, sortable: 'commissions.percentage'
end

sidebar :summary, only: :index, priority: 0 do
	columns do
		column do
			span 'Total SPA Value'
		end
		column do
			span number_to_currency(salevalues.sum('spa'), unit: 'RM ', delimeter: ',')
		end
	end
	columns do
		column do
			span 'Total Nett Value'
		end
		column do
			span number_to_currency(salevalues.sum('nett_value'), unit: 'RM ', delimeter: ',')
		end
	end
	columns do
		column do
			span 'Total Commision'
		end
		column do
			span number_to_currency(salevalues.sum('comm'), unit: 'RM ', delimeter: ',')
		end
	end	
	columns do
		column do
			span 'Total Sales'
		end
		column do
			span salevalues.per(salevalues.length * salevalues.total_pages).length
		end
	end

end

filter :user, label: 'REN'
filter :sale
filter :sale_date, as: :date_range
filter :sale_status, as: :select, collection: proc {Sale.statuses.map {|k,v| [k,v]}}
filter :project
filter :sale_unit_no, as: :string
filter :sale_buyer, as: :string
filter :percentage
filter :spa
filter :nett_value
filter :comm
filter :sale_unit_size, as: :numeric, label: 'Unit Size'
filter :sale_spa_value, as: :numeric, label: 'Unit SPA Value'
filter :sale_nett_value, as: :numeric, label: 'Unit Nett Value'

end
