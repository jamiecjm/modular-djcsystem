class Ability
  include CanCan::Ability

  def initialize(current_user)
    if current_user.nil?
      can :create, User
    else
      can :update, current_user
      can :read, User, id: current_user.pseudo_team_members.ids
      can :read, Team, id: current_user.pseudo_team.subtree.pluck(:id)
      can [:read, :update, :destroy, :email_report], Sale, id: current_user.pseudo_team_sales.pluck(:id)
      can [:read, :update, :destroy], Salevalue, sale: current_user.pseudo_team_sales
      can [:create], Sale
      can [:create], Salevalue
      can :read, ActiveAdmin::Page
      if current_user.leader?     
        can [:read, :update], User, id: current_user.pseudo_team_members.pluck(:id)
      end
      if current_user.admin?
        can :manage, :all
        cannot :destroy, Project, id: Project.where(id: Sale.pluck(:project_id)).ids
        cannot :destroy, User, id: User.where(id: Salevalue.pluck(:user_id)).ids
      end
    end
  end

end