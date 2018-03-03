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

permit_params :superteam_name, :email, :logo, :subdomain, :external_host

menu label: 'Company Profile', priority: 99, if: proc { current_user.admin? }

config.filters = false

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

index title: 'Company Profile', pagination_total: false do
	column 'Company Name', :superteam_name
	column :email
	column :logo
	column :subdomain
	column :external_host
	column :created_at
	column :updated_at
	actions
end

form do |f|
	inputs do
		input :superteam_name, label: 'Company Name'
		input :email
		input :logo, as: :file
		input :subdomain
		input :external_host
	end
	actions
end


end
