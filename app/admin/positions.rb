ActiveAdmin.register Position do
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

menu parent: 'Settings', priority: 1

permit_params :title, :overriding, :overriding_percentage, :default, :parent_id

config.filters = false

	index do
		id_column
		column :title
		column 'Manager', :parent
		column :overriding
		column :overriding_percentage
		actions
	end

	form do |f|
		inputs do
			input :title
			input :overriding
			input :overriding_percentage
			input :parent_id, label: 'Manager', as: :select, collection: Position.pluck(:title, :id)
			# input :default
		end

		actions
	end

end
