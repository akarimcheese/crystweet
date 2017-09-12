require "json"
require "http"
require "../response/cursors/user_id_cursor"

module Twitter::Request
    struct User
        @user_id : UInt64?
        @screen_name : String?
        
        def initialize(@client : Twitter::Rest::Client, @user_id : UInt64)
        end
        
        def initialize(@client : Twitter::Rest::Client, @screen_name : String)
        end
        
        # List Version
        def followers_list(cursor : UInt64? = nil, count : Int32? = nil, skip_status : Bool? = nil, include_user_identities : Bool? = nil)
            # TODO
        end
        
        # IDs version
        def followers_ids(cursor : UInt64? = nil, count : Int32? = nil, stringify_ids : Bool? = nil)
            endpoint = "followers/ids.json?"
        
            params = {} of String => (String | Nil)
            
            params["user_id"] = @user_id.to_s if @user_id
            params["screen_name"] = @screen_name if @screen_name
            params["cursor"] = cursor.to_s if cursor
            params["count"] = count.to_s if count
            params["stringify_ids"] = stringify_ids.to_s if stringify_ids
            params.compact! # Safekeeping
        
            response = get(endpoint, params)
            
            request = 
                ->(next_cursor : UInt64) { 
                    params["cursor"] = next_cursor.to_s
                    get(endpoint, params)
                }
            
            if stringify_ids
                Twitter::Response::UserIDCursor(String).new(
                    response.body, 
                    request
                )
            else
                Twitter::Response::UserIDCursor(UInt64).new(
                    response.body, 
                    request
                )
            end
        end
        
        # List Version
        def following_list(cursor : UInt64? = nil, count : Int32? = nil, skip_status : Bool? = nil, include_user_identities : Bool? = nil)
            # TODO
        end
        
        # IDs version
        def following_ids(cursor : UInt64? = nil, count : Int32? = nil, stringify_ids : Bool? = nil)
            endpoint = "friends/ids.json?"
        
            params = {} of String => (String | Nil)
            
            params["user_id"] = @user_id.to_s if @user_id
            params["screen_name"] = @screen_name if @screen_name
            params["cursor"] = cursor.to_s if cursor
            params["count"] = count.to_s if count
            params["stringify_ids"] = stringify_ids.to_s if stringify_ids
            params.compact! # Safekeeping
        
            response = get(endpoint, params)
            
            request = 
                ->(next_cursor : UInt64) { 
                    params["cursor"] = next_cursor.to_s
                    get(endpoint, params)
                }
            
            if stringify_ids
                Twitter::Response::UserIDCursor(String).new(
                    response.body, 
                    request
                )
            else
                Twitter::Response::UserIDCursor(UInt64).new(
                    response.body, 
                    request
                )
            end
        end
        
        # Find a way to refactor this to share code with other requests made
        def get(endpoint, params)
            encoded_params = HTTP::Params.encode(params)
            response = @client.get("https://api.twitter.com/1.1/#{endpoint}#{encoded_params}")
            
            return response
        end
    end
end