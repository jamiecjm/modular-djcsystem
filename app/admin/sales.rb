ActiveAdmin.register Sale do
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

permit_params :date, :project_id, :unit_no, :unit_size, :spa_value, :nett_value, :buyer, :package, :remark, :spa_sign_date, :la_date,
salevalues_attributes: [:user_id, :other_user, :percentage, :id, :sale_id, :_destroy],
other_salevalues_attributes: [:user_id, :other_user, :percentage, :id, :sale_id, :_destroy]

menu label: 'Team', priority: 1, parent: 'Sales'

includes :salevalues

scope 'Booked/Done', default: true do |sales|
	sales.not_cancelled
end

scope :cancelled do |sales|
	sales.search(status_eq: 2).result
end

scope :all

before_action only: :index do
	if params['q'].blank?
		params['q'] = {}
	end
	if params['q']['year'].blank?
		if params['q']['date_gteq'].blank?
			if Date.current >= Date.current.strftime('%Y-12-16').to_date
				params['q']['date_gteq'] = Date.current.strftime('%Y-12-16').to_date
			else
				params['q']['date_gteq'] = "#{Date.current.year-1}-12-16".to_date
			end
		end
		if params['q']['date_lteq'].blank?
			params['q']['date_lteq'] = Date.today
		end
	else
		year = params['q']['year']
		params['q']['date_gteq'] = "#{year.to_i-1}-12-16"
		params['q']['date_lteq'] = "#{year}-12-15"
	end
	if params['q']['upline_eq'].blank?
		params['q']['upline_eq'] = "[#{current_user.id}]"
	end
end

batch_action :change_status_of, form: {
	status: %w[Booked Done Cancelled]
	} do |ids, inputs|
		Sale.where(id: ids).update_all(status: inputs[:status])
		redirect_to collection_path, notice: "Sales with id #{ids.join(', ')} marked as #{inputs[:status]}"
end

member_action :email_report, method: :post do
	@id = resource.id
	respond_to do |format|
		format.js
	end
end

action_item :email_report, only: :show do
	link_to 'Email Report', email_report_sale_path, remote: true, method: :post
end

index title: 'Team Sales' do
	selectable_column
	id_column
	column :date
	column :status
	column :project
	column :unit_no
	column :buyer
	1.times do
		max_ren = (sales.map(&:salevalues).map(&:length)).max
		(1..max_ren).each do |x|
			list_column "REN #{x} (%)", sortable: 'users.name' do |sale|
				sv = sale.salevalues
				if sv[x-1]
					if sv[x-1].user.nil?
						[sv[x-1].other_user, "(#{sv[x-1].percentage}%)"]
					else
						[sv[x-1].user.prefered_name, "(#{sv[x-1].percentage}%)"]
					end
				else
					['-']
				end
			end
		end
	end
	number_column :unit_size, as: :currency, seperator: ',', unit: ''
	number_column :spa_value, as: :currency, seperator: ',', unit: ''
	number_column :nett_value, as: :currency, seperator: ',', unit: ''
	actions
end

sidebar :summary, only: :index, priority: 0 do
	columns do
		column do
			span 'Total SPA Value'
		end
		column do
			span @all_sales = sales.per(sales.length * sales.total_pages), style: "display: none"
			span number_to_currency(@all_sales.sum('salevalues.spa'), unit: 'RM ', delimeter: ',')
		end
	end
	columns do
		column do
			span 'Total Nett Value'
		end
		column do
			span number_to_currency(@all_sales.sum('salevalues.nett_value'), unit: 'RM ', delimeter: ',')
		end
	end
	columns do
		column do
			span 'Total Commision'
		end
		column do
			span number_to_currency(@all_sales.sum('salevalues.comm'), unit: 'RM ', delimeter: ',')
		end
	end	
	columns do
		column do
			span 'Total Sales'
		end
		column do
			span @all_sales.length
		end
	end
end

show do
		attributes_table do
			row :date
			list_row :ren do |s|
				s.salevalues.map {|sv| sv.user.prefered_name + " (#{sv.percentage}%)"}
			end
			list_row :other_ren do |s|
				s.other_salevalues.map {|sv| sv.other_user + " (#{sv.percentage}%)"}
			end
			row :project
			row :unit_no
			row :size
			row :spa_value do |s|
				number_to_currency(s.spa_value, unit: 'RM ', precision: 2 )
			end
			row :nett_value do |s|
				number_to_currency(s.nett_value, unit: 'RM ', precision: 2 )
			end
			row :buyer
			row :status
			row :package
			row :remark
		end

		attributes_table title: 'SPA and LA Sign Date' do
			
			row :spa_sign_date, label: 'SPA Sign Date'
			row :la_date, label: 'LA Sign Date'
			
		end
end

form do |f|
	# f.semantic_errors *f.object.errors.keys
	inputs do 
		input :date
		has_many :salevalues, :allow_destroy => true, new_record: 'Add REN', heading: 'REN' do |sv|
			sv.input :user, label: 'Name'
			sv.input :percentage, min: 0, step: 'any'
		end
		has_many :other_salevalues, :allow_destroy => true, new_record: 'Add Other Team\'s REN', heading: 'Other Team\'s REN' do |sv|
			sv.input :other_user, label: 'Name'
			sv.input :percentage
		end
		input :project
		input :unit_no
		input :unit_size, min: 0, step: 'any'
		input :spa_value, min: 0, step: 'any'
		input :nett_value, min: 0, step: 'any'
		input :buyer
		input :package
		input :remark
	end

	if !f.object.new_record?
		inputs do
			input :spa_sign_date
			input :la_date
		end
	end

	actions
end

filter :upline, as: :select, label: 'Upline', :collection => proc { current_user.pseudo_team_members.order('prefered_name').map { |u| [u.prefered_name, "[#{u.id}]"] } }
filter :year, as: :select, :collection => proc { (1900..Date.current.year+1).to_a.reverse }
filter :date
# filter :teams, as: :select, collection: proc { Team.where(overriding: true) }
filter :status, as: :select, collection: proc {Sale.statuses.map {|k,v| [k,v]}}
filter :project
filter :unit_no
filter :buyer
filter :users, label: 'REN'
# filter :users_location, label:'REN Location', as: :select, collection: User.locations.map {|k,v| [k,v]}
filter :unit_size
filter :spa_value
filter :nett_value

end
