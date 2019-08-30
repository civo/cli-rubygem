class AskService
  def self.available?
    STDIN.tty?
  end

  def self.choose(label, options)
    result = options.first
    printf "#{label} (#{options.join(", ")}) [#{options.first}]: "
    input = STDIN.gets.chomp
    result = input unless input.empty?
    unless options.include?(result)
      puts "That wasn't one of the available options.".colorize(:red) + " Please try again."
      result = choose(label, options)
    end
    result
  end
end

trap "SIGINT" do
  puts "Exiting..."
  exit 2
end
