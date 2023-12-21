module Schools
  class StandingPresenter < ApplicationPresenter
    def initialize(view_context, school)
      super(view_context)

      @school = school
    end

    def standing_enabled?
      @school.configuration["enable_standing"]
    end

    def standings
      @standings ||= @school.standings.where(archived_at: nil).order(:id)
    end

    def standing_log_count_for_each_unarchived_standing
      UserStanding
        .where(standing: standings, archived_at: nil)
        .group(:standing_id)
        .count
    end

    def school_has_code_of_conduct?
      SchoolString::CodeOfConduct.saved?(@school)
    end
  end
end