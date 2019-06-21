module CivoCLI
  class Spinner
    @spinner_shapes = ['|', '/', '-', '\\']
    @counter = 0
    @spinner_frame = 0
    def self.spin
      while @counter < 600
        sleep(0.1)
        print @spinner_shapes[@spinner_frame] + "\b"
        @spinner_frame += 1
        @spinner_frame = 0 if @spinner_frame == @spinner_shapes.length
        @counter += 1
      end
    rescue Interrupt, IRB::Abort
      print "\b\b" + "Exiting.\n"
      exit 1
    end
  end
end
