class BugAssignmentMailer < ApplicationMailer
  def assigned_email
    @bug = params[:bug]
    mail(
      to: @bug.assigned_user.email,
      subject: "A new bug has been assigned to you"
    )
  end
end
