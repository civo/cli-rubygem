module CivoCLI
  print "\033[?25l"
  class Spinner
    SPINNER_SHAPES = ['|', '/', '-', '\\'].freeze
    DELAY = 0.1

    attr_accessor :data

    def self.spin(data = {}, &block)
      new(data, &block).spin
    end

    def initialize(data = {}, &block)
      @data = data
      @spinner_frame = 0
      @counter = 20
      @total = 3600 / DELAY
      @block = block
      spin
    end

    def method_missing(name)
      @data[name] if @data.keys.include?(name)
    end

    def [](key)
      @data[key] if @data.keys.include?(key)
    end

    def []=(key, value)
      @data[key] = value
    end

    def spin
      print "\033[?25l"
      while(@total > 0) do
        sleep(DELAY)
        print SPINNER_SHAPES[@spinner_frame] + "\b"
        @spinner_frame += 1
        @spinner_frame = 0 if @spinner_frame == SPINNER_SHAPES.length
        @counter -= 1
        @total -= 1
        next unless @counter == 0

        @counter = 20
        if result = @block.call(self)
          self.data[:result] = result
          print "\033[?25h"
          return self
        end
      end

      print "\033[?25h"
    rescue Interrupt
      print "\b\b" + "Exiting.\n"
      exit 1
    ensure
      print "\033[?25h"
    end
  end
end
