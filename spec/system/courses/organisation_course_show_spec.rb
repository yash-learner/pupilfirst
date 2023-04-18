require 'rails_helper'

feature 'Organisation show' do
  include UserSpecHelper

  let(:school) { create :school, :current }

  let!(:organisation_1) { create :organisation, school: school }
  let!(:organisation_2) { create :organisation, school: school }

  let(:school_admin_user) { create :user, school: school }

  let!(:school_admin) do
    create :school_admin, school: school, user: school_admin_user
  end

  let(:org_admin_user) { create :user, school: school }

  let!(:org_admin) do
    create :organisation_admin,
           organisation: organisation_1,
           user: org_admin_user
  end

  let(:regular_user) { create :user, school: school }

  # Two courses.
  let(:course_1) { create :course }
  let(:course_2) { create :course }

  # Three cohorts in course 1, one of which has ended, and one cohort in course 2.
  let(:cohort_1) { create :cohort, course: course_1 }
  let(:cohort_2) { create :cohort, course: course_1 }
  let(:cohort_3) { create :cohort, course: course_1, ends_at: 1.day.ago }
  let(:cohort_4) { create :cohort, course: course_2 }

  # Now the students in org 1.
  let!(:team_c1_o1) { create :team_with_students, cohort: cohort_1 }
  let!(:team_c2_o1) { create :team_with_students, cohort: cohort_2 }
  let!(:team_c3_o1) { create :team_with_students, cohort: cohort_3 }
  let!(:team_c4_o1) { create :team_with_students, cohort: cohort_4 }

  # Org 2 has some active students in cohort 1 as well.
  let!(:team_c1_o2) { create :team_with_students, cohort: cohort_1 }

  # And then a team not in any org.
  let!(:team_c1_no_org) { create :team_with_students, cohort: cohort_1 }

  before do
    # Set up org relationships
    [team_c1_o1, team_c2_o1, team_c3_o1, team_c4_o1].each do |team|
      team
        .founders
        .includes(:user)
        .each { |f| f.user.update!(organisation: organisation_1) }
    end

    team_c1_o2
      .founders
      .includes(:user)
      .each { |f| f.user.update!(organisation: organisation_2) }
  end

  context 'when the user is an organisation admin' do
    scenario 'user can see all the active and inactive cohorts' do
      sign_in_user(org_admin_user, referrer: organisation_course_path(organisation_1, course_1))

      expect(page).to have_text("#{course_1.name}")

      expect(page).to have_text("Active Cohorts\n2")
      expect(page).to have_text("Ended Cohorts\n1")

      # Checking active cohorts.
      within(
        "div[class='border border-green-500 bg-gray-50 rounded-lg p-5']"
      ) do
        expect(page).to have_text("Active Cohorts")

        expect(page).to have_link(
          cohort_1.name,
          href: organisation_cohort_path(organisation_1, cohort_1)
        )

        expect(page).to have_link(
          cohort_2.name,
          href: organisation_cohort_path(organisation_1, cohort_2)
        )
      end

      # Checking ended cohorts.
      within(
        "div[class='border border-red-500 bg-gray-50 rounded-lg p-5']"
      ) do
        expect(page).to have_text("Ended Cohorts")

        expect(page).not_to have_link(
          cohort_1.name,
          href: organisation_cohort_path(organisation_1, cohort_1)
        )

        expect(page).to have_link(
          cohort_3.name,
          href: organisation_cohort_path(organisation_1, cohort_3)
        )
      end

      # Visit the course 2 page.
      visit organisation_course_path(organisation_1, course_2)

      expect(page).to have_text("#{course_2.name}")

      expect(page).to have_text("Active Cohorts\n1")
      expect(page).to have_text("Ended Cohorts\n0")

      # Checking active cohorts.
      within(
        "div[class='border border-green-500 bg-gray-50 rounded-lg p-5']"
      ) do
        expect(page).to have_text("Active Cohorts")

        expect(page).to have_link(
          cohort_4.name,
          href: organisation_cohort_path(organisation_1, cohort_4)
        )
      end

      # Checking ended cohorts.
      within(
        "div[class='border border-red-500 bg-gray-50 rounded-lg p-5']"
      ) do
        expect(page).to have_text("Ended Cohorts")
        expect(page).to have_text("No ended cohorts for this course.")
      end
    end

    scenario 'check the working of back button' do
      sign_in_user(org_admin_user, referrer: organisation_course_path(organisation_1, course_1))

      expect(page).to have_text("#{course_1.name}")

      click_link cohort_1.name

      expect(page).to have_current_path(organisation_cohort_path(organisation_1, cohort_1))
      expect(page).to have_text("#{cohort_1.name}")
      expect(page).to have_link("Back")

      click_link "Back"

      expect(page).to have_current_path(organisation_course_path(organisation_1, course_1))

      click_link cohort_1.name

      expect(page).to have_current_path(organisation_cohort_path(organisation_1, cohort_1))
      expect(page).to have_text("#{cohort_1.name}")
      expect(page).to have_link("Back")


      expect(page).to have_link(
        "Students",
        href: students_organisation_cohort_path(organisation_1, cohort_1)
      )

      click_link "Students"
      expect(page).to have_current_path(students_organisation_cohort_path(organisation_1, cohort_1))

      click_link "Back"
      expect(page).to have_current_path(organisation_cohort_path(organisation_1, cohort_1))

      click_link "Back"
      expect(page).to have_current_path(organisation_course_path(organisation_1, course_1))
    end
  end

  context 'when the user is a school admin' do
    scenario 'user can see all the active and inactive cohorts' do
      sign_in_user(school_admin_user, referrer: organisation_course_path(organisation_1, course_1))

      expect(page).to have_text("#{course_1.name}")

      expect(page).to have_text("Active Cohorts\n2")
      expect(page).to have_text("Ended Cohorts\n1")

      # Checking active cohorts.
      within(
        "div[class='border border-green-500 bg-gray-50 rounded-lg p-5']"
      ) do
        expect(page).to have_text("Active Cohorts")

        expect(page).to have_link(
          cohort_1.name,
          href: organisation_cohort_path(organisation_1, cohort_1)
        )

        expect(page).to have_link(
          cohort_2.name,
          href: organisation_cohort_path(organisation_1, cohort_2)
        )
      end

      # Checking ended cohorts.
      within(
        "div[class='border border-red-500 bg-gray-50 rounded-lg p-5']"
      ) do
        expect(page).to have_text("Ended Cohorts")

        expect(page).not_to have_link(
          cohort_1.name,
          href: organisation_cohort_path(organisation_1, cohort_1)
        )

        expect(page).to have_link(
          cohort_3.name,
          href: organisation_cohort_path(organisation_1, cohort_3)
        )
      end

      # Visit the course 2 page.
      visit organisation_course_path(organisation_1, course_2)

      expect(page).to have_text("#{course_2.name}")

      expect(page).to have_text("Active Cohorts\n1")
      expect(page).to have_text("Ended Cohorts\n0")

      # Checking active cohorts.
      within(
        "div[class='border border-green-500 bg-gray-50 rounded-lg p-5']"
      ) do
        expect(page).to have_text("Active Cohorts")

        expect(page).to have_link(
          cohort_4.name,
          href: organisation_cohort_path(organisation_1, cohort_4)
        )
      end

      # Checking ended cohorts.
      within(
        "div[class='border border-red-500 bg-gray-50 rounded-lg p-5']"
      ) do
        expect(page).to have_text("Ended Cohorts")
        expect(page).to have_text("No ended cohorts")
      end
    end

    scenario 'check the working of back button' do
      sign_in_user(school_admin_user, referrer: organisation_course_path(organisation_1, course_1))

      expect(page).to have_text("#{course_1.name}")

      click_link cohort_1.name

      expect(page).to have_current_path(organisation_cohort_path(organisation_1, cohort_1))
      expect(page).to have_text("#{cohort_1.name}")
      expect(page).to have_link("Back")

      click_link "Back"

      expect(page).to have_current_path(organisation_course_path(organisation_1, course_1))

      click_link cohort_1.name

      expect(page).to have_current_path(organisation_cohort_path(organisation_1, cohort_1))
      expect(page).to have_text("#{cohort_1.name}")
      expect(page).to have_link("Back")


      expect(page).to have_link(
        "Students",
        href: students_organisation_cohort_path(organisation_1, cohort_1)
      )

      click_link "Students"
      expect(page).to have_current_path(students_organisation_cohort_path(organisation_1, cohort_1))

      click_link "Back"
      expect(page).to have_current_path(organisation_cohort_path(organisation_1, cohort_1))

      click_link "Back"
      expect(page).to have_current_path(organisation_course_path(organisation_1, course_1))
    end
  end

  context 'when the user is a non-admin' do
    scenario 'user can not see the course show page' do
      sign_in_user(regular_user, referrer: organisation_course_path(organisation_1, course_1))

      expect(page).to have_http_status(:not_found)
    end
  end
end
