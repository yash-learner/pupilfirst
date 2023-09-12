module AuthorizeViewSubmissions
  include ActiveSupport::Concern

  def authorized?
    return true if current_school_admin.present?

    return false if current_user&.faculty.blank?

    return false if course&.school != current_school

    current_user.faculty.courses.exists?(id: course)
  end
end
