ActiveAdmin.register Project do
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

menu parent: 'Projects', label: 'List'

includes :sales, commissions: [positions_commissions: :position]

permit_params :name, commissions_attributes: [:effective_date, :id, :project_id, :_destroy, 
	positions_commissions_attributes: [:position_id, :commission_id, :id, :percentage]]

scope :all, default: true do |projects|
	comms = Commission.where(project_id: projects.ids)
	@max_comms = comms.joins(:project).group('projects.id').count.values.max
	projects
end

batch_action :destroy, false

index pagination_total: false do
	selectable_column
	id_column
	column :name
	column :sales_count do |p|
		link_to pluralize(p.sales.length, 'sale'), sales_path(q: {project_id_in: p.id}), target: '_blank'
	end
	list_column 'Commissions (%)' do |p|
		comms = {}
		p.commissions.each {|c| 
			comms[c.effective_date] = {}
			c.positions_commissions.each do |pc|
				comms[c.effective_date][pc.position.display_name] = "#{pc.percentage}%" 
			end
		}
		comms
	end
	column :created_at
	column :updated_at
	actions
end

show do
	attributes_table do
		row :name
		row :sales_count do |p|
			link_to pluralize(p.sales.length, 'sale'), sales_path(q: {project_id_eq: p.id})
		end
		list_row 'Commissions (%)' do |p|
			comms = {}
			p.commissions.each {|c| 
				comms[c.effective_date] = {}
				c.positions_commissions.each do |pc|
					comms[c.effective_date][pc.position.display_name] = "#{pc.percentage}%" 
				end
			}
			comms
		end
		row :created_at
		row :updated_at
	end
end

form do |f|
	f.semantic_errors *f.object.errors.keys
	inputs do
		input :name
		has_many :commissions, allow_destroy: true do |c|
			c.input :effective_date
			c.has_many :positions_commissions, allow_destroy: false, new_record: false do |pc|
				pc.input :position, input_html: {readonly: "readonly"}
				pc.input :percentage, min: 0
			end
		end
	end
	actions
end

filter :name
filter :commissions_percentage, as: :numeric
filter :commissions_effective_date, as: :date_range

csv do
	column :id
	column :name
	column(:sales_count) do |p|
		p.sales.length
	end
	(1..controller.instance_variable_get(:@max_comms)).each do |x|
		column("Commission #{x} (%)") do |p|
			comm = p.commissions.order(:effective_date)[x-1]
			if comm
				"#{comm.percentage}"
			else
				nil
			end
		end
		column("Commission #{x} Effective Date") do |p|
			comm = p.commissions.order(:effective_date)[x-1]
			if comm
				"#{comm.effective_date}"
			else
				nil
			end
		end
	end
	column :created_at
	column :updated_at
end

end
