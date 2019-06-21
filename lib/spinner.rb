module CivoCLI
  class Spinner
    @spinner_shapes = ['|', '/', '-', '\\'].freeze
    @counter = 20
    @spinner_frame = 0

    def self.detect_build_status(id)
      result = []
      Civo::Instance.all.items.each do |instance|
        result << instance
      end
      result.select! { |instance| instance.hostname.include?(id) }
      result[0].status
    end

    def self.spin(id)
      loop do
        sleep(0.1)
        print @spinner_shapes[@spinner_frame] + "\b"
        @spinner_frame += 1
        @spinner_frame = 0 if @spinner_frame == @spinner_shapes.length
        @counter -= 1
        next unless @counter.zero?
        break if detect_build_status(id) == 'ACTIVE'

        @counter = 20
      end
    rescue Interrupt, IRB::Abort
      print "\b\b" + "Exiting.\n"
      exit 1
    end
  end
end
