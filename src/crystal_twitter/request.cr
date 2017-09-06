module Twitter
    struct Request
        property client, url, params
        
        def initialize(@client : HTTP::Client, endpoint, params)
            @url = "https://api.twitter.com/1.1/#{endpoint}"
            
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
        
        def exec
            response = @client.get("#{@url}#{@params.to_s}")
            if response.status_code == 429
                # Replace with typed exception
                raise "Rate Limit Exceeded. Wait 15 minutes."
            end
            return response
        end
    end
end