# frozen_string_literal: true

module Jason
  module Math
    module Utility
      # A crude progress tracker/estimator
      class CompletionEstimator
        def initialize
          @then = Time.now
        end

        def seconds_remaining(percentage_complete)
          return Float::INFINITY if percentage_complete.zero?

          elapsed = Time.now - @then
          total_time = elapsed / percentage_complete

          (1 - percentage_complete) * total_time
        end
      end
    end
  end
end
