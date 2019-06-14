module Founders
  class TimelinePanelPresenter < ApplicationPresenter
    def initialize(event, founder, current_founder)
      @event = event
      @founder = founder
      @current_founder = current_founder
    end

    def detailed_description
      "After #{target_prefix(@event.target)} <em>#{@event.target.title}:</em>\n #{@event.description}"
    end

    def review_pending?
      @event.evaluator_id.blank? && !@event.passed?
    end

    def not_accepted?
      @event.evaluator_id.present? && !@event.passed?
    end

    def founder_not_exited?
      @current_founder && !@current_founder.exited && (@current_founder == @founder)
    end

    private

    def target_prefix(target)
      case target.target_action_type
        when Target::TYPE_TODO
          'executing'
        when Target::TYPE_ATTEND
          'attending'
        when Target::TYPE_LEARN
          'watching'
        when Target::TYPE_READ
          'reading'
      end
    end
  end
end
