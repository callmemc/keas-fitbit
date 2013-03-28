module ClientHelper
  # Load the existing yml config and use consumer key/secret to initialize new Fitgem client
  def initialize_client
    config = begin
      Fitgem::Client.symbolize_keys(YAML.load(File.open("config/fitgem.yml")))
    rescue ArgumentError => e
      puts "Could not parse YAML: #{e.message}"
    end
    return Fitgem::Client.new(config[:oauth])
  end
  
  def reconnect_client(token, secret)
    client = initialize_client
    client.reconnect(token, secret)
    return client
  end
  
end
