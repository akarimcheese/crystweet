require "http/server"

module Twitter
    struct Request
        property client, url, params, retry_on_limit
        
        @@endpoint_mapping = Twitter::EndpointMapping.new
        
        def initialize(@client : Twitter::Client, endpoint, params)
            if params.is_a?(Hash(String,String))
                new_params = {} of String=>Array(String)
                
                params.each do |key, val|
                    new_params[key] = [val]
                end
                
                params = new_params
            end
        
            @url = "https://api.twitter.com/1.1/#{@@endpoint_mapping[endpoint]}"
            @verb = :GET
            @retry_on_limit = false
            
            @params = HTTP::Params.new(params)
        end
        
        def for_user(id : UInt64)
            @params.add("user_id", id)
            self
        end
        
        def for_user(name : String)
            @params.add("screen_name", name)
            self
        end
        
        def with_cursor(cursor : UInt64)
            @params.set_all("cursor", [cursor.to_s])
            self
        end
        
        def with_query(query : String)
            @params.add("q", query)
            self
        end
        
        def ignore_rate_limit
            @retry_on_limit = true
            self
        end
        
        def as_post
            @verb = :POST
            self
        end
        
        def exec
            response : HTTP::Client::Response
            
            case @verb
            when :POST
                @client.oauth
                response = @client.client.post_form(@url, params.to_s)
            else
                @client.oauth
                response = @client.client.get("#{@url}#{@params.to_s}")
            end
            
            if response.status_code == 429
                # Perhaps add a nonblocking option
                if @retry_on_limit
                    puts "Rate limit reached... sleeping and retrying after 15 minutes..."
                    sleep(15*60 + 5)
                    return exec
                else
                    # Replace with typed exception
                    raise JSON.parse(response.body)["errors"].map{|err| err["message"].as_s }.join(",")
                end
            end
            return response
        end
    end
end