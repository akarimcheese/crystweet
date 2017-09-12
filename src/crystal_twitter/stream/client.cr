require "../client"

module Twitter::Stream
    class Client < Twitter::Client
        
        def base_url
            "stream.twitter.com"
        end
        
        def api_version
            "1.1"
        end
        
        def stream
            oauth()
            
            params = "track=nfl"
            
            puts "we out here"
            
            @client.connect_timeout = 60*60*24
            @client.read_timeout = 60*60*24
            
            @client.post("https://stream.twitter.com/1.1/statuses/filter.json?#{params}") do |response|
              puts "we in here"
              puts response.inspect
              puts response.status_code  # => 200
              while !response.body_io.closed?
                puts response.body_io.gets("\r\n")
              end
            end
        end
    end
end