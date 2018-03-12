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

includes :commissions, :sales

permit_params :name, commissions_attributes: [:percentage, :effective_date, :id, :project_id, :_destroy]

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
	list_column 'Commission(%) | Effective Date' do |p|
		p.commissions.map {|c| "#{c.percentage}% | #{c.effective_date}" }
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
		list_row 'Commission(%) | Effective Date' do |p|
			p.commissions.map {|c| "#{c.percentage}% | #{c.effective_date}" }
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
			c.input :position
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
