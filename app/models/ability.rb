class Ability
  include CanCan::Ability

  def initialize(current_user)
    if current_user.admin?
      can [:read, :update], Website
    end
  	if current_user.leader?
  		can :manage, Project
      can :create, User
  		can [:read, :update], User, id: current_user.pseudo_team_members.pluck(:id)
      can :destroy, User, id: User.where.not(id: Salevalue.pluck(:user_id)).ids
  	else
  		can :read, Project
      can :update, current_user
  		can :read, User, id: current_user.pseudo_team_members.ids
  	end
    if current_user.nil?
      can :create, User
    end
    can :read, Team, id: current_user.pseudo_team.subtree.pluck(:id)
  	can :manage, Sale
    can :manage, Salevalue, sale: current_user.pseudo_team_sales
    can :create, Sale
    can :create, Salevalue
    can :read, ActiveAdmin::Page
  end

end