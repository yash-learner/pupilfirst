class NullObjectPolicy < ApplicationPolicy
  def show?
    false
  end

  alias apply? show?
  alias curriculum? show?
  alias leaderboard? show?
  alias review? show?
  alias cohorts? show?
  alias report? show?
  alias calendar? show?
  alias calender_month_data? show?
  alias process_application? show?
end
