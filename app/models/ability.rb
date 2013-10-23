class Ability
  include CanCan::Ability

  def initialize(current_user)
    role = current_user && current_user.role ? current_user.role : :user
    send role, current_user if current_user
  end

  def admin current_user
    can :manage, Application, trusted: true
    can :manage, Application, user_id: current_user.id
  end

  def user current_user
    can :manage, Application, user_id: current_user.id
    cannot :create_trusted, Application
  end
end
