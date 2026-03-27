class DailyReportJob
  include Sidekiq::Job

  def perform
    require "csv"

    # 1️⃣ Ensure reports folder exists
    reports_dir = Rails.root.join("public/reports")
    FileUtils.mkdir_p(reports_dir)

    # 2️⃣ CSV file path
    file_path = reports_dir.join("daily_report_#{Date.today}.csv")

    # 3️⃣ Generate CSV
    CSV.open(file_path, "w") do |csv|
      csv << [ "Project", "Total Bugs", "New", "Started", "Resolved/Completed" ]

      Project.includes(:bugs).find_each do |project|
        bugs = project.bugs

        csv << [
          project.title,
          bugs.count,
          bugs.where(status: "new").count,
          bugs.where(status: "started").count,
          bugs.where(status: [ "resolved", "completed" ]).count
        ]
      end
    end

    # 4️⃣ Send email
    ReportMailer.daily_report(file_path.to_s).deliver_now
  end
end
