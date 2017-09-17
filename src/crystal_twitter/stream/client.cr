require "../client"

module Twitter::Stream
    class Client < Twitter::Client
        
        def base_url
            "stream.twitter.com"
        end
        
        def api_version
            "1.1"
        end
        
        # Info regarding params: https://dev.twitter.com/streaming/overview/request-parameters
        # TODO: add and handle locations, delimited, & stall params
        def stream(follow : Array(UInt64)? = nil, track : Array(String)? = nil)
            oauth()
            
            if follow && follow.size > 5000
                raise "Cannot follow more than 5000 user ids"
            elsif track && track.size > 400
                raise "Cannot track more than 400 keywords"
            end
            
            params = {} of String => (String | Nil)
            
            params["follow"] = follow.join(",") if follow
            params["track"] = track.join(",") if track
            params.compact! # Safekeeping
            
            # TODO: check if the 2 lines below are necessary
            @client.connect_timeout = 60*60*24
            @client.read_timeout = 60*60*24
            
            @client.post_form("https://stream.twitter.com/1.1/statuses/filter.json?", params) do |response|
              while !response.body_io.closed?
                # TODO: Yield tweet object, only yield string if param as_strings = true
                # do this through some proc idk
                # yield response.body_io.gets("\r\n")
                
                # FIXME: break these two lines up into better, readable steps
                string = response.body_io.gets("\r\n")
                if string
                    puts string
                    puts "Tweet keys"
                    puts JSON.parse(string).as_h.keys.inspect
                    t = JSON.parse(string)
                    if t["retweeted_status"]?
                        puts "RT status keys"
                        puts JSON.parse(string)["retweeted_status"].as_h.keys.inspect
                        puts "RT user keys"
                        puts JSON.parse(string)["retweeted_status"]["user"].as_h.keys.inspect
                    end
                    if t["quoted_status"]?
                        puts "RT User keys"
                        puts JSON.parse(string)["quoted_status"].as_h.keys.inspect
                        puts "Quote user keys"
                        puts JSON.parse(string)["quoted_status"]["user"].as_h.keys.inspect
                    end
                    h = JSON.parse(string)["user"].as_h.keys.inspect
                end
                puts JSON.parse(string).as_h["user"] if string
                yield Twitter::Response::Tweet.new(JSON::PullParser.new(string)) if string
              end
            end
        end
    end
end