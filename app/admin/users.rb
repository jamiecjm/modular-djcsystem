ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  menu parent: 'Teams', label: 'Members'

  scope :all, default: true

  scope :pending, if: proc { current_user.leader? }

  before_action only: :index do
    if params['q'].blank?
      params['q'] = {}
    end
    if params['q']['upline_eq'].blank?
      params['q']['upline_eq'] = "[#{current_user.id}]"
    end
  end

  batch_action :approve, if: proc {current_user.leader?}, confirm: "Are you sure?" do |ids, inputs|
      User.unscoped.where(id: ids).update_all(approved?: true)
      redirect_to collection_path, notice: "Users with id #{ids.join(', ')} has been approved"
  end

  batch_action :disapprove, if: proc {current_user.leader?}, confirm: "Are you sure?" do |ids, inputs|
    User.where(id: ids).update_all(approved?: false)
    redirect_to collection_path, notice: "Users with id #{ids.join(', ')} has been disapproved"
  end

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
        if f.object.new_record? || current_user.leader?
          input :team, as: :select, collection: Team.where(overriding: true)
          input :parent_id, label: 'Referrer', as: :select, collection: User.all.order(:prefered_name).map {|u| [u.prefered_name, u.id ]}
          input :location
        end
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

  filter :upline_eq, as: :select, label: 'Upline', :collection => proc { current_user.pseudo_team_members.order('prefered_name').map { |u| [u.prefered_name, "[#{u.id}]"] } }
  filter :team,as: :select, collection: proc { Team.where(overriding: true) }
  filter :referrer_eq, as: :select, label: 'Referrer', :collection => proc { current_user.pseudo_team_members.order('prefered_name').map { |u| [u.prefered_name, "[#{u.id}]"] } }
  filter :location, as: :select, collection: User.locations.map {|k,v| [k,v]}
  filter :name
  filter :prefered_name
  filter :email
  filter :phone_no
  filter :birthday


end
