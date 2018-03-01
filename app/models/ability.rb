class Ability
  include CanCan::Ability

  def initialize(current_user)
    if current_user.admin?
      can [:read, :update], Website
    end
  	if current_user.leader?
  		can :manage, Project
  		can [:read, :update, :destroy], User, id: current_user.pseudo_team_members.pluck(:id)
  	else
  		can :read, Project
  		can :read, User, id: current_user.pseudo_team_members
  		can :update, current_user
  	end
    can :read, Team, id: current_user.pseudo_team.subtree.pluck(:id)
  	can :manage, Salevalue
  	can :manage, Sale
    can :read, ActiveAdmin::Page
  end

end