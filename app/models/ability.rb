class Ability
  include CanCan::Ability

  def initialize(current_user)
    send current_user.role, current_user unless current_user.nil? || current_user.role.blank?
  end

  def admin current_user
    can :manage, :all
  end

  def user current_user
  end
end