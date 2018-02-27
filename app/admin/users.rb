ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  menu parent: 'Teams', label: 'Members'

  scope :approved, default: true

  scope :pending, if: proc { current_user.leader? }

  index do
    selectable_column
    id_column
    column :name
    column :prefered_name
    column :email
    column :phone_no
    column :birthday
    column :team
    column 'Referrer', :parent
    column :location
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    inputs do
        input :name
        input :prefered_name
        input :email
        input :phone_no
        input :birthday
        input :parent, label: 'Referrer', as: :select, collection: User.all.map {|u| [u.prefered_name, u.id ]}
        input :location
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :prefered_name
      row :email
      row :phone_no
      row :birthday
      row :team
      row 'Referrer' do
        user.parent
      end
      row :location
      row :created_at
      row :updated_at
    end
  end

  filter :name
  filter :prefered_name
  filter :email
  filter :phone_no
  filter :birthday
  filter :team
  filter :parent
  filter :location, as: :select, collection: User.locations.map {|k,v| [k,v]}

end
