require "../../rest/client"

module Twitter::Request
    struct UserLookup
        # Pls just use one or the other
        @user_id : (Array(UInt64) | Array(String) | Nil)
        @screen_name : (Array(String) | Nil)
    
        def initialize(@client : Twitter::Rest::Client, @user_id : Array(UInt64))
        end
        
        def initialize(@client : Twitter::Rest::Client, identifiers : Array(String), using_user_id : Bool? = nil)
            if using_user_id
                @screen_name = identifiers
            else
                @user_id = identifiers
            end
        end
        
        def initialize(@client : Twitter::Rest::Client, user_id : UInt64)
            @user_id = [user_id]
        end
        
        def initialize(@client : Twitter::Rest::Client, identifier : String, using_user_id : Bool? = nil)
            if using_user_id
                @screen_name = [identifier]
            else
                @user_id = [identifier]
            end
        end
        
        # TODO: entity support
        def lookup_users(include_entities : Bool? = nil)
            endpoint = "https://api.twitter.com/1.1/users/lookup.json?"
            user_ids, screen_names = @user_id, @screen_name
            
            param_key : String
            identifiers : Array(UInt64) | Array(String)
            users = [] of Twitter::Response::User
            
            if user_ids
                param_key = "user_id"
                identifiers = user_ids
            elsif screen_names
                param_key = "screen_name"
                identifiers = screen_names
            else
                raise "Can't lookup empty list of users"
            end
            
            identifiers.each_slice(100) do |slice|
                params = {} of String => (String | Nil)
            
                params[param_key] = slice.join(",")
                params["include_entities"] = include_entities.to_s if include_entities
                
                response = @client.post(endpoint, params)
                parser = JSON::PullParser.new(response.body)
                users_slice = Array(Twitter::Response::User).new(parser)
                users.concat(users_slice)
            end
            
            
            return users
        end
        
        def lookup_friendships()
            raise "Not implemented"
            # TODO
            # https://dev.twitter.com/rest/reference/get/friendships/lookup
        end
        
        # TODO: Single user lookup here or in Twitter::Request::User
    end
end