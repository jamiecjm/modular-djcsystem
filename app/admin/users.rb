ActiveAdmin.register User do
  permit_params :name, :prefered_name, :ic_no, :phone_no, :birthday, :team_id, :parent_id, :location, :email, :password, :password_confirmation, :admin

  menu parent: 'Teams', label: 'Members'

  includes :positions, team: :leader

  scope :approved, default: true

  scope :pending, if: proc { current_user.admin? }

  scope :archived, if: proc { current_user.admin? }, show_count: false do |users|
    users.where(archived: true)
  end

  before_action only: :index do
    if params['q'].blank?
      params['q'] = {}
    end
    if params['q']['upline_eq'].blank?
      params['q']['upline_eq'] = "[#{current_user.id}]"
    end
  end

  batch_action :approve, confirm: "Are you sure?", if: proc {current_user.admin? && params['scope']=='pending'} do |ids, inputs|
      User.where(id: ids).update_all(locked_at: nil)
      UserMailer.notify(User.where(id: ids), current_website).deliver
      redirect_to collection_path, notice: "Users with id #{ids.join(', ')} has been approved"
  end

  batch_action :disapprove, confirm: "Are you sure?", if: proc {current_user.admin? && (params['scope']=='approved' || params['scope'].nil?) } do |ids, inputs|
    User.where(id: ids).update_all(locked_at: Time.now)
    redirect_to collection_path, notice: "Users with id #{ids.join(', ')} has been disapproved"
  end

  batch_action :archive, confirm: "Are you sure?", if: proc {current_user.admin? && (params['scope']=='pending' || params['scope'] == 'approved' || params['scope'].nil?)} do |ids, inputs|
    User.where(id: ids).update_all(archived: true, locked_at: Time.now)
    redirect_to collection_path, notice: "Users with id #{ids.join(', ')} has been archived"
  end

  batch_action :unarchive, confirm: "Are you sure?", if: proc {current_user.admin? && params['scope']=='archived'} do |ids, inputs|
    User.where(id: ids).update_all(archived: false)
    redirect_to collection_path, notice: "Users with id #{ids.join(', ')} has been unarchived"
  end

  batch_action :destroy, false

  index pagination_total: false do
    selectable_column
    id_column
    column :name
    column :prefered_name
    column :position do |u|
      u.positions.last
    end
    column :ic_no
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
    f.semantic_errors *f.object.errors.keys
    inputs do
        input :name
        input :prefered_name
        input :ic_no
        input :email
        input :phone_no
        input :birthday
        if current_user.leader?
          input :team, as: :select, collection: Team.where(overriding: true)
          input :parent_id, label: 'Referrer', as: :select, collection: User.approved.order(:prefered_name).map {|u| [u.prefered_name, u.id ]}
          input :location
        end
        if current_user.admin?
          input :admin
        end
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :prefered_name
      row :position do |u|
        u.positions.last
      end
      row :ic_no
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

  filter :upline_eq, as: :select, label: 'Upline', :collection => proc { User.approved.accessible_by(current_ability).order(:prefered_name).map { |u| [u.prefered_name, "[#{u.id}]"] } }
  filter :team,as: :select, collection: proc { (Team.accessible_by(current_ability).includes(:leader).main + [current_user.team]).uniq }, input_html: {multiple: true}
  filter :referrer_eq, as: :select, label: 'Referrer', :collection => proc { User.order(:prefered_name).map { |u| [u.prefered_name, "[#{u.id}]"] } }
  filter :location, as: :select, collection: User.location.options, input_html: {multiple: true}
  filter :name
  filter :prefered_name
  filter :email
  filter :phone_no
  filter :birthday

  csv do
    column :id
    column :name
    column :prefered_name
    column :ic_no
    column :email
    column :phone_no
    column :birthday
    column(:team) { |u| u.team.display_name}
    column('Referrer') { |u| u.parent&.prefered_name}
    column :location
    column :created_at
    column :updated_at
  end


end
