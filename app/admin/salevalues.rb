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

config.sort_order = 'sales.date_desc'

includes :sale, :project, :commission

scope 'Booked/Done', default: true, show_count: false do |sv|
	sv = sv.not_cancelled
	@total_spa = sv.pluck('spa').inject(:+)
	@total_nett_value = sv.pluck('nett_value').inject(:+)
	@total_comm = sv.pluck('comm').inject(:+)
	@total_sales = sv.length
	sv
end

scope :cancelled, show_count: false do |sv|
	sv = sv.cancelled
	@total_spa = sv.pluck('spa').inject(:+)
	@total_nett_value = sv.pluck('nett_value').inject(:+)
	@total_comm = sv.pluck('comm').inject(:+)
	@total_sales = sv.length
	sv
end

scope :all, show_count: false do |sv|
	@total_spa = sv.pluck('spa').inject(:+)
	@total_nett_value = sv.pluck('nett_value').inject(:+)
	@total_comm = sv.pluck('comm').inject(:+)
	@total_sales = sv.length
	sv
end

before_action only: :index do 
	if params['q'].blank?
		params['q'] = {}
	end
	if params['q']['user_id_eq'].blank?
		params['q']['user_id_eq'] = current_user.id
	else
		unless current_user.pseudo_team_members.pluck(:id).include?(params['q']['user_id_eq'].to_i)
			redirect_to root_path, alert: 'You are not authorized to perform this action.'
		end
	end
	if params['q']['year'].blank?
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
	else
		year = params['q']['year']
		params['q']['sale_date_gteq_datetime'] = "#{year.to_i-1}-12-16"
		params['q']['sale_date_lteq_datetime'] = "#{year}-12-15"
	end

end

batch_action :change_status_of, form: {
	status: %w[Booked Done Cancelled]
	} do |ids, inputs|
		sales = Sale.search(salevalues_id_in: ids).result(distinct: true)
		sales.update_all(status: inputs[:status])
		redirect_to collection_path, notice: "Sales with id #{sales.ids.join(', ')} marked as #{inputs[:status]}"
end

member_action :view do |sv|
	redirect_to sale_path(sv.sale)
end

member_action :edit do |sv|
	redirect_to edit_sale_path(sv.sale)
end

controller do
	before_action :denied, only: [:show, :edit, :destroy]
	def show
	end
	def edit
	end
	def destroy
	end
end

index title: 'Individual Sales', pagination_total: false do |sv|
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
			span number_to_currency(controller.instance_variable_get(:@total_spa), unit: 'RM ', delimeter: ',')
		end
	end
	columns do
		column do
			span 'Total Nett Value'
		end
		column do
			span number_to_currency(controller.instance_variable_get(:@total_nett_value), unit: 'RM ', delimeter: ',')
		end
	end
	columns do
		column do
			span 'Total Commision'
		end
		column do
			span number_to_currency(controller.instance_variable_get(:@total_comm), unit: 'RM ', delimeter: ',')
		end
	end	
	columns do
		column do
			span 'Total Sales'
		end
		column do
			span controller.instance_variable_get(:@total_sales)
		end
	end

end

filter :user, label: 'REN', :collection => proc { current_user.pseudo_team_members.order('prefered_name').pluck(:prefered_name, :id) }
filter :sale
filter :year, as: :select, :collection => proc { (1900..Date.current.year+1).to_a.reverse }
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

csv do
	column(:sale) {|sv| sv.sale.display_name }
	column(:date) do |sv|
		sv.sale.date
	end
	column(:status) do |sv|
		sv.sale.status
	end
	column(:project) {|sv| sv.project.name}
	column(:unit_no) do |sv|
		sv.sale.unit_no
	end
	column(:buyer) do |sv|
		sv.sale.buyer
	end
	column('REN Sale Percentage') {|sv| sv.percentage}
	column('REN SPA Value') {|sv| sv.spa}
	column('REN Nett Value') {|sv| sv.nett_value}
	column('REN Commission') {|sv| sv.comm}
	column(:unit_size) do |sv|
		sv.sale.unit_size
	end
	column(:unit_spa_value) do |sv|
		sv.sale.spa_value
	end
	column(:unit_nett_value) do |sv|
		sv.sale.nett_value
	end	
	column(:commission) {|sv| sv.commission.percentage}
end

end
