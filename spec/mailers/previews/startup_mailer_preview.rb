class StartupMailerPreview < ActionMailer::Preview
  def feedback_as_email_with_grade
    startup_feedback =
      StartupFeedback.new(
        id: 1,
        feedback: "This is the feedback text.\n\nIt is multi-line.",
        timeline_event:
          TimelineEvent.new(
            id: 2,
            founders: [Founder.first],
            target: Target.new(id: 1, title: 'Super Cool Target')
          ),
        faculty: Faculty.last
      )
    StartupMailer.feedback_as_email(startup_feedback, true)
  end

  def feedback_as_email
    startup_feedback =
      StartupFeedback.new(
        id: 1,
        feedback: "This is the feedback text.\n\nIt is multi-line.",
        timeline_event:
          TimelineEvent.new(
            id: 2,
            founders: [Founder.first],
            target: Target.new(id: 1, title: 'Super Cool Target')
          ),
        faculty: Faculty.last
      )

    StartupMailer.feedback_as_email(startup_feedback, false)
  end
end
