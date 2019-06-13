class CreateAnswerMutator < ApplicationMutator
  include AuthorizeCommunityUser

  attr_accessor :description
  attr_accessor :question_id

  validates :description, length: { minimum: 1, maximum: 5000, message: 'InvalidLengthDescription' }
  validates :question_id, presence: { message: 'BlankQuestionId' }

  def create_answer
    answer = Answer.transaction do
      question.update!(last_activity_at: Time.zone.now)

      Answer.create!(
        creator: current_user,
        question: question,
        description: description
      )
    end

    answer.id
  end

  private

  alias authorized? authorized_create?

  def community
    @community ||= question&.community
  end

  def question
    @question ||= Question.find_by(id: question_id)
  end
end