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

permit_params :title, :overriding, :default, :parent_id

config.batch_actions = false

config.filters = false

actions :all, except: :show

before_action only: :index do
	params['per_page'] = '1'
end

index as: :barchart, download_links: false do
	positions = Position.all.map {|p|
		phash = {
			v: p.title,
			f: p.title+'<br/>'+(link_to 'Edit', edit_position_path(p.id)).delete('\"')+'&nbsp;'+(link_to 'Delete', "/positions/#{p.id}", method: :delete, 'data-confirm': "Sure?").delete('\"')
		}
		[phash, p.parent&.title]
	}
	render partial: 'positions/org_chart', :locals => {positions: positions.to_json}, layout: 'layouts/chart'
end

form do |f|
	inputs do
		input :title
		input :parent_id, label: 'Upline', as: :select, collection: Position.pluck(:title, :id)
	end

	actions
end

end
