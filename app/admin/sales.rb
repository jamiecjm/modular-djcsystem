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
main_salevalues_attributes: [:user_id, :other_user, :percentage, :id, :sale_id, :_destroy],
other_salevalues_attributes: [:user_id, :other_user, :percentage, :id, :sale_id, :_destroy]

menu label: 'Team', priority: 1, parent: 'Sales'

config.sort_order = 'date_desc'

includes :commission, :project, :other_salevalues, main_salevalues: :user

scope 'Booked/Done', default: true, show_count: false do |sales|
	sales = sales.not_cancelled
	sv = Salevalue.where(sale_id: sales.ids)
	@max_ren = sv.joins(:sale).group('sales.id').count.values.max
	team_sv = sv.where(other_user: nil)
	@total_spa = team_sv.pluck('spa').inject(:+)
	@total_nett_value = team_sv.pluck('nett_value').inject(:+)
	@total_comm = team_sv.pluck('comm').inject(:+)
	@total_sales = sales.length
	sales
end

scope :cancelled, show_count: false do |sales|
	sales = sales.search(status_eq: "Cancelled").result
	sv = Salevalue.where(sale_id: sales.ids)
	@max_ren = sv.joins(:sale).group('sales.id').count.values.max
	team_sv = sv.where(other_user: nil)
	@total_spa = team_sv.pluck('spa').inject(:+)
	@total_nett_value = team_sv.pluck('nett_value').inject(:+)
	@total_comm = team_sv.pluck('comm').inject(:+)
	@total_sales = sales.length
	sales
end

scope :all, show_count: false do |sales|
	sv = Salevalue.where(sale_id: sales.ids)
	@max_ren = sv.joins(:sale).group('sales.id').count.values.max
	team_sv = sv.where(other_user: nil)
	@total_spa = team_sv.pluck('spa').inject(:+)
	@total_nett_value = team_sv.pluck('nett_value').inject(:+)
	@total_comm = team_sv.pluck('comm').inject(:+)
	@total_sales = sales.length
	sales
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
	if params['q']['month'].blank?
		params['q']['date_gteq'] = "#{params['q']['year'].to_i-1}-12-16".to_date
		params['q']['date_lteq'] = params['q']['date_gteq'] + 1.year - 1.day
	else
		month = params['q']['month'].to_date.month
		params['q']['date_gteq'] = "#{params['q']['year']}-#{month}-1".to_date
		params['q']['date_lteq'] = params['q']['date_gteq'] + 1.month - 1.day		
	end
	if params['q']['upline_eq'].blank?
		params['q']['upline_eq'] = "[#{current_user.id}]"
	end
	if params['scope'].nil? || params['scope'] == 'booked_done'
		if params['q']['status_in'].blank?
			params['q']['status_in'] = ["Booked","Done"]
		end
	end
end

batch_action :change_status_of, form: {
	status: %w[Booked Done Cancelled]
	} do |ids, inputs|
		Sale.where(id: ids).update_all(status: inputs[:status])
		redirect_to collection_path, notice: "Sales with id #{ids.join(', ')} marked as #{inputs[:status]}"
end

batch_action :destroy, false

member_action :email_report, method: :post do
	@sale = resource
	@user = current_user
	@company_name = current_website.superteam_name
	respond_to do |format|
		format.js
	end
end

member_action :send_report do
	sale = Sale.find(params[:id])
	to = params[:to].gsub(/\s+/, '').split(',')
	UserMailer.email_admin(user: current_user, sale: sale, to: to, subject: params['subject'], 
		content: params['content'], company: current_website).deliver
end

action_item :email_report, only: :show do
	link_to 'Email Report', email_report_sale_path, remote: true, method: :post
end

controller do
	def create
		super
		if resource.id
			UserMailer.generate_report(resource, current_website).deliver
		end
	end
end

index title: 'Team Sales', pagination_total: false do
	selectable_column
	id_column
	column :date
	tag_column :status
	column :project
	column :unit_no
	column :buyer
	(1..controller.instance_variable_get(:@max_ren)).each do |x|
		list_column "REN #{x} (%)" do |sale|
			sv = sale.main_salevalues + sale.other_salevalues
			if sv[x-1]
				if sv[x-1].user.nil?
					[sv[x-1].other_user, "(#{sv[x-1].percentage}%)"]
				else
					if can? :read, sv[x-1].user
						[(link_to sv[x-1].user.prefered_name, salevalues_path(q: {user_id_eq: sv[x-1].user.id, sale_id_eq: sale.id, year: sale.date.year}), target: '_blank'), "(#{sv[x-1].percentage}%)"]
					else
						[sv[x-1].user.prefered_name, "(#{sv[x-1].percentage}%)"]
					end
				end
			else
				nil
			end
		end
	end
	number_column :unit_size, as: :currency, seperator: ',', unit: ''
	number_column :spa_value, as: :currency, seperator: ',', unit: ''
	number_column :nett_value, as: :currency, seperator: ',', unit: ''
	column 'Commission Percentage (%)', :commission
	number_column :commission, as: :currency, seperator: ',', unit: '' do |sale|
		sale.nett_value * sale.commission.percentage/100
	end
	actions
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

show do
	attributes_table do
		row :date
		tag_row :status
		row :project
		row :unit_no
		row :buyer
		list_row :ren do |s|
			s.salevalues.map {|sv| 
				if sv.user.nil?
					sv.other_user + " (#{sv.percentage}%)"
				else
					sv.user.prefered_name + " (#{sv.percentage}%)"
				end
			}
		end
		number_row :unit_size, as: :currency, seperator: ',', unit: ''
		number_row :spa_value, as: :currency, seperator: ',', unit: ''
		number_row :nett_value, as: :currency, seperator: ',', unit: ''
		row 'Commission Percentage (%)' do |sale|
			sale.commission
		end
		number_row :commission, as: :currency, seperator: ',', unit: '' do |sale|
			sale.nett_value * sale.commission.percentage/100
		end
		row :package
		row :remark
	end

	attributes_table title: 'SPA and LA Sign Date' do
		
		row :spa_sign_date, label: 'SPA Sign Date'
		row :la_date, label: 'LA Sign Date'
		
	end
end

form do |f|
	f.semantic_errors *f.object.errors.keys
	inputs do 
		input :date
		has_many :main_salevalues, :allow_destroy => true, new_record: 'Add REN', heading: 'REN', sortable: :order, sortable_start: 1 do |sv|
			sv.input :user, label: 'Name', as: :select, collection: User.approved.order(:prefered_name).map {|u| [u.prefered_name, u.id ]}
			sv.input :percentage, min: 0, step: 'any'
		end
		has_many :other_salevalues, :allow_destroy => true, new_record: 'Add Other Team\'s REN', heading: 'Other Team\'s REN', sortable: :order, sortable_start: 1 do |sv|
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

filter :upline, as: :select, label: 'Upline', :collection => proc { User.approved.accessible_by(current_ability).order('prefered_name').map { |u| [u.prefered_name, "[#{u.id}]"] } }
filter :year, as: :select, :collection => proc { ((Sale.order('date asc').first.date.year-1)..Date.current.year+1).to_a.reverse }
filter :month, as: :select, :collection => proc { (1..12).to_a.map{|m| Date::MONTHNAMES[m] }}
# filter :date
# filter :teams, as: :select, collection: proc { Team.where(overriding: true) }
filter :status, as: :select, collection: Sale.status.options, input_html: {multiple: true}
filter :project, input_html: {multiple: true}
filter :unit_no
filter :buyer
filter :users, label: 'REN', input_html: {multiple: true}
# filter :users_location, label:'REN Location', as: :select, collection: User.locations.map {|k,v| [k,v]}
filter :unit_size, as: :numeric_range_filter
filter :spa_value, as: :numeric_range_filter
filter :nett_value, as: :numeric_range_filter

csv do
	column :id
	column :date
	column :status
	column(:project) {|sale| sale.project.name}
	column :unit_no
	column :buyer
	(1..controller.instance_variable_get(:@max_ren)).each do |x|
		column("REN #{x}") {|sale|
			sv = (sale.main_salevalues + sale.other_salevalues).flatten[x-1]
			if sv
				if sv.user.nil?
					sv.other_user
				else
					sv.user.prefered_name
				end
			else
				nil
			end
		}
		column("REN #{x} Comm Percentage (%)") {|sale|
			sv = (sale.main_salevalues + sale.other_salevalues).flatten[x-1]
			if sv
				sv.percentage
			else
				nil
			end
		}
	end
	column :unit_size
	column :spa_value
	column :nett_value
	column(:commission_percentage) {|sale| sale.commission.percentage}
	column(:commission) {|sale| sale.nett_value * sale.commission.percentage/100 }
end

end
