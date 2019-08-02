module CivoCLI
  class Timer

    attr_accessor :time_elapsed

    def start_timer
      @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def end_timer
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      @time_elapsed = (end_time - @start_time).round(2)
    end
  end
end