ActiveAdmin.register Website, as: 'Company Profile' do
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

permit_params :superteam_name, :email, :logo, :logo_cache, :remove_logo, :subdomain, :external_host

menu parent: 'Settings', label: 'Company Profile', priority: 2

config.filters = false
config.current_filters = false

before_action only: :index do
	if params['q'].blank?
		params['q'] = {}
	end
	website = Website.where(external_host: request.host)
	if website.blank?
	    subdomain = request.host.split('.')[0]
	    params['q']['subdomain_eq'] = subdomain
	else
		params['q']['external_host_eq'] = request.host
	end
end

before_action except: :index do
	if params[:id].to_i != current_website.id
		redirect_to root_path, alert: 'You are not authorized to perform this action.'
	end
end

member_action :remove_logo do
	resource.remove_logo!
	respond_to do |format|
		format.js
	end
end

index title: 'Company Profile', pagination_total: false, download_links: false do
	column 'Company Name', :superteam_name
	column :email
	column :logo do |w|
		image_tag w.logo.thumb.url if w.logo?
	end
	column :subdomain
	column :external_host
	column :created_at
	column :updated_at
	actions
end

show do
	attributes_table do
	 	row 'Company Name' do |w| 
	 		w.superteam_name
	 	end
		row :email
		row :logo do |w|
			image_tag w.logo.thumb.url if w.logo?
		end
		row :subdomain
		row :external_host
		row :created_at
		row :updated_at
	end
end

form do |f|
	f.semantic_errors *f.object.errors.keys
	inputs do
		input :superteam_name, label: 'Company Name'
		input :email
	  	input :logo, :as => :file, :hint => f.object.logo? \
	  	? image_tag(f.object.logo.thumb.url)
	  	: content_tag(:span, '')
	  	input :logo_cache, :as => :hidden
	  	if f.object.logo?
	  		input :remove_logo, as: :boolean, :label => link_to('Remove', remove_logo_company_profile_path, remote: true)
	  	end
		input :subdomain
		input :external_host
	end
	actions
end


end
