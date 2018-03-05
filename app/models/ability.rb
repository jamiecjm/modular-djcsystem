class Ability
  include CanCan::Ability

  def initialize(current_user)

    if current_user.admin?
      can [:read, :update], Website
      can :remove_logo, Website
    end

  	if current_user.leader?
  		can [:create, :read, :update], Project
      can :destroy, Project, id: Project.where.not(id: Sale.pluck(:project_id)).ids
      can :manage, Commission
      can :create, User
  		can [:read, :update], User, id: current_user.pseudo_team_members.pluck(:id)
      can :destroy, User, id: User.where.not(id: Salevalue.pluck(:user_id)).ids
      can [:update], Team, id: current_user.pseudo_team.subtree.pluck(:id)
  	else
  		can :read, Project
      can :update, current_user
  		can :read, User, id: current_user.pseudo_team_members.ids
  	end

    if current_user.nil?
      can :create, User
    else
      can :read, Team, id: current_user.pseudo_team.subtree.pluck(:id)
      can [:read, :update, :destroy, :email_report], Sale, id: current_user.pseudo_team_sales.pluck(:id)
      can [:read, :update, :destroy], Salevalue, sale: current_user.pseudo_team_sales
      can [:create], Sale
      can [:create], Salevalue
      can :read, ActiveAdmin::Page
    end

  end

end