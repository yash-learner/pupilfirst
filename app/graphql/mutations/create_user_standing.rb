module Mutations
  class CreateUserStanding < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :student_id, ID, required: true
    argument :reason, String, required: true
    argument :standing_id, ID, required: true

    description "Create a new standing log"

    field :user_standing, Types::UserStandingType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.create_standing_log.success_notification")
      )
      { user_standing: create_user_standing }
    end

    private

    def create_user_standing
      UserStanding.transaction do
        user_standing =
          UserStanding.create!(
            user_id: student.user.id,
            reason: @params[:reason],
            standing_id: @params[:standing_id],
            creator: current_user
          )

        send_email

        user_standing
      end
    end

    def send_email
      previous_standing, current_standing =
        if user_standings.count > 1
          [user_standings.second.standing, user_standings.first.standing]
        else
          [
            Standing.where(school_id: resource_school.id, default: true).first,
            user_standings.first.standing
          ]
        end

      UserMailer.email_change_in_user_standing(
        student.user,
        current_standing.name,
        previous_standing.name,
        @params[:reason]
      ).deliver_later
    end

    def user_standings
      @user_standings ||=
        UserStanding
          .where(user_id: student.user.id, archived_at: nil)
          .order(created_at: :desc)
          .limit(2)
    end

    def resource_school
      student&.school
    end

    def student
      @student ||= Student.find(@params[:student_id])
    end
  end
end
