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

permit_params :name, commissions_attributes: [:percentage, :effective_date, :id, :project_id, :_destroy]

index do
	selectable_column
	id_column
	column :name
	1.times do
		max_comms = (projects.map(&:commissions).map(&:length)).max
		(1..max_comms).each do |x|
			column "Commission #{x} | Effective Date" do |p|
				comms = p.commissions
				if comms[x-1]
					"#{comms[x-1].percentage}% | #{comms[x-1].effective_date}"
				else
					'-'
				end
			end
		end
	end
	column :created_at
	column :updated_at
	actions
end

form do |f|
	inputs do
		input :name
		has_many :commissions, allow_destroy: true do |c|
			c.input :percentage
			c.input :effective_date
		end
	end
	actions
end

filter :name
filter :commissions_percentage, as: :numeric
filter :commissions_effective_date, as: :date_range


end
