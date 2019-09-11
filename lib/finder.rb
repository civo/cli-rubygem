class Finder
  def self.detect_cluster(id)
    result = []
    Civo::Kubernetes.all.items.each do |cluster|
      result << cluster
    end

    matched = result.detect { |cluster| cluster.name == id || cluster.id == id }
    return matched if matched

    result.select! { |cluster| cluster.name.include?(id) || cluster.id.include?(id) }

    if result.count.zero?
      puts "No Kubernetes clusters found for '#{id}'. Please check your query."
      exit 1
    elsif result.count > 1
      puts "Multiple possible Kubernetes clusters found for '#{id}'. Please try with a more specific query."
      exit 1
    else
      result[0]
    end
  end

  def self.detect_app(name)
    result = []
    apps = Civo::Kubernetes.applications.items
    apps.each do |app|
      result << app if app.name.downcase.include?(name.downcase)
    end

    matched = apps.detect { |app| app.name.downcase == name.downcase }
    return matched if matched

    if result.count.zero?
      puts "No Kubernetes marketplace applications found for '#{name}'. Please check your query."
      exit 1
    elsif result.count > 1
      puts "Multiple possible Kubernetes marketplace applications found for '#{name}'. Please try with a more specific query."
      exit 1
    else
      result[0]
    end
  end
end
