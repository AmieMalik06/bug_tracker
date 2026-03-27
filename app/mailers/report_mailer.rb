class ReportMailer < ApplicationMailer
  default from: ENV["GMAIL_USERNAME"]   # use your Gmail account

  def daily_report(file_path)
    attachments["daily_report.csv"] = File.read(file_path)

    mail(
      to: "sarmadjaved.08@gmail.com",
      subject: "Daily Bug Report"
    )
  end
end
