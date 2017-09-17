require "json"
require "http"

module Twitter::Request
    class Search
        @query : String
        
        def initialize(@client : Twitter::Rest::Client, @query : String)
        end
        
        def users(page : Int32? = nil, count : Int32? = nil, include_entities : Bool? = nil)
            endpoint = "users/search.json?"
        
            params = {} of String => (String | Nil)
            
            params["q"] = @query
            params["page"] = page.to_s if page
            params["count"] = count.to_s if count
            params["include_entities"] = include_entities.to_s if include_entities
            params.compact! # Safekeeping
        
            response = get(endpoint, params)
            
            # TODO: Cursor-like thing for pages
            # 
            # request = 
            #     ->(next_cursor : UInt64) { 
            #         params["cursor"] = next_cursor.to_s
            #         get(endpoint, params)
            #     }
            # Twitter::Response::UserIDCursor(UInt64).new(
            #     response.body, 
            #     request
            # )
            
            parser = JSON::PullParser.new(response.body)
            Array(Twitter::Response::User).new(parser)
        end
        
        def tweets()
            raise "Not implemented"
            # TODO : https://dev.twitter.com/rest/reference/get/search/tweets
        end
        
        def geo()
            raise "Not implemented"
            # https://dev.twitter.com/rest/reference/get/geo/search
        end
        
        # Abstract this for all requests, maybe
        def get(endpoint, params)
            encoded_params = HTTP::Params.encode(params)
            response = @client.get("https://api.twitter.com/1.1/#{endpoint}#{encoded_params}")
            
            return response
        end
    end
end