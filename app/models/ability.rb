class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # MANAGER PERMISSIONS
    if user.manager?
      can :manage, Project
      can :manage, Bug
      can :assign_users, Project
    end

    # QA PERMISSIONS
    if user.qa?
      # QA can only see assigned projects
      can :read, Project, users: { id: user.id }

      # QA can create bugs
      can :create, Bug

      # QA can edit/delete only bugs they created
      can [ :update, :destroy ], Bug, creator_id: user.id
    end

    # DEVELOPER PERMISSIONS
    if user.developer?
      # Developer can only see assigned projects
      can :read, Project, users: { id: user.id }

      # Developer can read bugs
      can :read, Bug

      # Developer can only update bug status
      can :update, Bug
    end
  end
end
