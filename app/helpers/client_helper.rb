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

  def authorize_client(client, token, verifier, request_token)
    secret = request_token[:secret]
    begin
      access_token = client.authorize(token, secret, { :oauth_verifier => verifier })
    rescue Exception => e
      return false
      puts "Error: Could not authorize Fitgem::Client with supplied oauth verifier: " + verifier
    end
    return access_token 
  end  
end
