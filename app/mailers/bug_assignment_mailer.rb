class BugAssignmentMailer < ApplicationMailer
  default from: ENV["GMAIL_USERNAME"]  # your Gmail account

  def assigned_email(notification)
    @notification = notification
    @bug = notification.params[:bug]
    @actor = notification.params[:actor]

    mail(
      to: @bug.assigned_user.email,
      subject: "New Bug Assigned: #{@bug.title}"
    )
  end
end
