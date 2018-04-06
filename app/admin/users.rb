ActiveAdmin.register User do
  permit_params :name, :prefered_name, :ic_no, :phone_no, :birthday, :team_id, :parent_id, :location, :email, :admin, :password, :password_confirmation,
  teams_attributes: [:id, :title, :user_id, :position_id, :parent_id, :effective_date, :locked, :_destroy, :upline_id, :hidden]

  menu parent: 'Team', label: 'Members'

  scope :approved, default: true

  scope :pending, if: proc { current_user.admin? }

  scope :archived, if: proc { current_user.admin? }, show_count: false do |users|
    users.where(archived: true)
  end


  batch_action :approve, confirm: "Are you sure?", if: proc {current_user.admin? && params['scope']=='pending'} do |ids, inputs|
      User.where(id: ids).update_all(locked_at: nil)
      UserMailer.notify(User.where(id: ids), current_website).deliver
      redirect_back fallback_location: collection_path, notice: "Users with id #{ids.join(', ')} has been approved"
  end

  batch_action :disapprove, confirm: "Are you sure?", if: proc {current_user.admin? && (params['scope']=='approved' || params['scope'].nil?) } do |ids, inputs|
    User.where(id: ids).update_all(locked_at: Time.now)
    redirect_back fallback_location: collection_path, notice: "Users with id #{ids.join(', ')} has been disapproved"
  end

  batch_action :archive, confirm: "Are you sure?", if: proc {current_user.admin? && (params['scope']=='pending' || params['scope'] == 'approved' || params['scope'].nil?)} do |ids, inputs|
    User.where(id: ids).update_all(archived: true, locked_at: Time.now)
    redirect_back fallback_location: collection_path, notice: "Users with id #{ids.join(', ')} has been archived"
  end

  batch_action :unarchive, confirm: "Are you sure?", if: proc {current_user.admin? && params['scope']=='archived'} do |ids, inputs|
    User.where(id: ids).update_all(archived: false)
    redirect_back fallback_location: collection_path, notice: "Users with id #{ids.join(', ')} has been unarchived"
  end

  batch_action :change_upline_of, if: proc {current_user.admin?}, form: {
    upline: User.order(:prefered_name).pluck(:prefered_name),
    effective_date: :datepicker
    } do |ids, inputs|
      inputs[:upline] = nil if inputs[:upline] == 'null'
      if inputs[:effective_date].blank?
        redirect_back fallback_location: collection_path, alert: 'Effective Date must not be blank.'
      else
        upline = User.find(inputs[:upline]).current_team
        User.where(id: ids).find_each do |u|
          new_team = u.current_team.dup
          new_team.attributes = {parent_id: upline.id, upline_id: upline.id, effective_date: inputs[:effective_date], hidden: false}
          new_team.save
        end
        redirect_back fallback_location: collection_path
      end
  end


  batch_action :destroy, false

  action_item :change_password, only: :show, if: proc {resource == current_user} do
    link_to "Change password", edit_user_registration_path
  end

  collection_action :get_all do
    render json: User.order(:prefered_name).pluck(:id, :prefered_name)
  end

  index pagination_total: false do
    selectable_column
    id_column
    column :name
    column :prefered_name
    column :current_position
    column :ic_no
    column :email
    column :phone_no
    column :birthday
    column 'Immediate Upline' do |user|
      user.upline
    end
    column :referrer
    column :location
    column :sales_count do |user|
      sales = user.sales
      link_to pluralize(sales.length, 'sale'), sales_path(q: {users_id_in: user.id, date_gteq: sales.first&.date}), target: '_blank'
    end
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
        if current_user.admin?
          # input :team, as: :select, collection: Team.where(overriding: true)
          input :parent_id, label: 'Referrer', as: :select, collection: User.order(:prefered_name).map {|u| [u.prefered_name, u.id ]}
          input :location
          input :admin
        end
    end

    if current_user.admin?
      inputs do
        f.has_many :teams, scope: :visible, heading: 'Position', new_record: 'Add New Position' do |t|
          t.input :position, label: 'Title'
          t.input :upline
          unless t.object == f.object.teams.first
            t.input :effective_date
            t.input :_destroy, label: 'Delete', as: :boolean unless t.object.new_record?
          end
          t.input :hidden, as: :hidden, input_html: {value: false}
        end
      end

      inputs do
        input :password
        input :password_confirmation
      end
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :prefered_name
      row :current_position
      row :ic_no
      row :email
      row :phone_no
      row :birthday
      row 'Immediate Upline' do |user|
        user.upline
      end
      row :referrer
      row :location
      row :created_at
      row :updated_at
      # list_row 'Tree View' do
      #   user.current_team.subtree.joins(:user).arrange_serializable(:order => 'users.prefered_name') do |parent, children|
      #     tree_hash =
      #     {
      #        Name: parent.user.prefered_name,
      #        Downline: children
      #     }
      #     tree_hash.slice!(:Name) if tree_hash[:Downline].blank?
      #     tree_hash
      #   end
      # end
    end

    # panel 'Family Tree' do
    # end
  end

  filter :upline_eq, as: :select, label: 'Upline', :collection => proc { User.accessible_by(current_ability).map { |u| [u.prefered_name, "[#{u.id}]"] } }
  # filter :team,as: :select, collection: proc { (Team.accessible_by(current_ability).includes(:user).main + [current_user.team]).uniq }, input_html: {multiple: true}
  filter :upline, label: 'Immediate Upline'
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
    column(:current_position) do |user|
      user.current_position.title
    end
    column :ic_no
    column :email
    column :phone_no
    column :birthday
    column('Immediate Upline') do |user|
      user.upline&.display_name
    end
    column(:referrer) do |user|
      user.referrer&.display_name
    end
    column :location
    column :created_at
    column :updated_at
  end


end
