class Ability
  include CanCan::Ability

  def initialize(current_user)
    if current_user.nil?
      can :create, User
    else
      can :update, current_user
      can :read, User, id: current_user.current_team_members.ids
      can :read, Team, id: current_user.all_team_subtree.pluck(:id)
      can [:read, :update, :destroy, :email_report], Sale, id: current_user.all_team_sales.pluck(:id)
      can [:read, :update, :destroy], Salevalue, sale: current_user.all_team_sales
      can [:create], Sale
      can [:create], Salevalue
      can :read, ActiveAdmin::Page
      if current_user.admin?
        can :manage, :all
        cannot [:create, :destroy], Team
        cannot [:create, :destroy], Website
      end
    end
  end

end