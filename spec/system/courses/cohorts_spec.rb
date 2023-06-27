require "rails_helper"

feature "Cohorts", js: true do
  include UserSpecHelper

  let!(:school) { create :school, :current }

  let!(:course_coach) { create :faculty, school: school }

  let!(:course) { create :course, school: school }

  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:level_3) { create :level, :three, course: course }

  let!(:target_group_l1) { create :target_group, level: level_1 }

  let!(:target_group_l2) { create :target_group, level: level_2 }

  let!(:target_l1) do
    create :target,
           target_group: target_group_l1,
           role: Target::ROLE_STUDENT,
           evaluation_criteria: [evaluation_criterion],
           milestone: true,
           milestone_number: 1
  end
  let!(:target_l2) do
    create :target,
           target_group: target_group_l2,
           role: Target::ROLE_STUDENT,
           evaluation_criteria: [evaluation_criterion],
           milestone: true,
           milestone_number: 2
  end

  let(:cohort_1) { create :cohort, course: course }
  let(:cohort_2) { create :cohort, course: course }
  let(:cohort_3) { create :cohort, course: course, ends_at: 1.day.ago }
  let(:cohort_4) { create :cohort, course: course }

  # Create few students
  let!(:student_1) do
    create :founder, tag_list: ["starts with z", "vegetable"], cohort: cohort_1
  end # This will always be around the bottom of the list.
  let!(:student_2) do
    create :founder, tag_list: ["vegetable"], cohort: cohort_1
  end # This will always be around the top.
  let!(:student_3) { create :founder, cohort: cohort_1 }
  let!(:student_4) { create :founder, cohort: cohort_1 }
  let!(:student_5) { create :founder, cohort: cohort_1 }
  let!(:student_6) { create :founder, cohort: cohort_1 }

  before do
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort_1
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort_2
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort_3
    student_1.user.update!(name: "Zucchini", last_seen_at: 3.minutes.ago)
    student_2.user.update!(name: "Asparagus")
    student_3.user.update!(name: "Banana")
    student_4.user.update!(name: "Blueberry")
    student_5.user.update!(name: "Cherry")
    student_6.user.update!(name: "Elderberry")

    30.times do
      user = create :user, name: "C #{Faker::Lorem.word} #{rand(10)}"

      # These will be in the middle of the list.
      create :student, cohort: cohort_1, user: user
    end

    5.times do
      user = create :user, name: "A #{Faker::Lorem.word} #{rand(10)}"

      # These will be around the top of the list.
      create :student, cohort: cohort_2, user: user
    end

    3.times do
      user = create :user, name: "B #{Faker::Lorem.word} #{rand(10)}"

      # These will be around the bottom of the list.
      create :student, cohort: cohort_3, user: user
    end
  end

  context "when the user is a course coach" do
    scenario "can see all the active cohorts where they are a coach" do
      sign_in_user course_coach.user, referrer: cohorts_course_path(course)

      expect(page).to have_text(course.name)

      expect(page).to have_text("41 students enrolled in 2 active cohorts")

      expect(page).to have_text("Active Cohorts")

      expect(page).to have_text(cohort_1.name)
      expect(page).to have_text(cohort_2.name)
      expect(page).not_to have_text(cohort_4.name)
    end

    scenario "can see all the the ended cohorts where they are a coach" do
      sign_in_user course_coach.user,
                   referrer: cohorts_course_path(course, status: "ended")

      expect(page).to have_text(course.name)

      expect(page).to have_text("3 students enrolled in 1 ended cohort")

      expect(page).to have_text("Ended Cohorts")

      expect(page).to have_text(cohort_3.name)
    end

    scenario "visits an active cohort page" do
      sign_in_user course_coach.user, referrer: cohorts_course_path(course)

      click_link cohort_1.name

      expect(page).to have_text(cohort_1.name)

      expect(page).to have_text(course.name)

      expect(page).to have_text("Overview")

      expect(page).to have_text("Students")

      expect(page).to have_text("Student Distribution by Milestone Completion")

      expect(page).to have_text("M1: " + target_l1.title)
      expect(page).to have_text("0/36")
      expect(page).to have_text("M2: " + target_l2.title)
      expect(page).to have_text("0/36")

      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_1],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      visit cohort_path(cohort_1)

      expect(page).to have_text("1/36")

      visit students_cohort_path(cohort_1)
      expect(page).to have_current_path(students_cohort_path(cohort_1))
    end

    scenario "visits the students tab inside a cohort" do
      sign_in_user course_coach.user, referrer: cohorts_course_path(course)

      visit students_cohort_path(cohort_1)

      expect(page).to have_text(student_1.name)
      expect(page).to have_text(student_2.name)

      visit student_report_path(student_1)
      expect(page).to have_current_path(student_report_path(student_1))

      expect(page).to have_text(student_1.name)
      expect(page).to have_text("Milestone Targets Completion Status")
    end

    scenario "filters stduents by email" do
      sign_in_user course_coach.user, referrer: students_cohort_path(cohort_1)

      fill_in "Filter", with: student_1.email
      click_button "Email: #{student_1.email}"

      expect(page).to have_text(student_1.name)
      expect(page).not_to have_text(student_2.name)

      find("button[title='Remove selection: #{student_1.email}']").click
      expect(page).to have_text(student_2.name)
    end

    scenario "filters stduents by name" do
      sign_in_user course_coach.user, referrer: students_cohort_path(cohort_1)

      fill_in "Filter", with: student_1.name
      click_button "Name: #{student_1.name}"

      expect(page).to have_text(student_1.name)
      expect(page).not_to have_text(student_2.name)

      find("button[title='Remove selection: #{student_1.name}']").click
      expect(page).to have_text(student_2.name)
    end
  end

  context "when the user isn't signed in" do
    scenario "user is required to sign in" do
      visit cohorts_course_path(course)

      expect(page).to have_text("Sign in to #{school.name}")
    end
  end

  context "when the user is a student" do
    scenario "user is not allowed to view the page" do
      sign_in_user student_1.user, referrer: cohorts_course_path(course)

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end
  end
end