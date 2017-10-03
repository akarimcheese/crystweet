require "json"
require "http"
require "../response/relationship"

module Twitter::Request
    class Relationship
        @source_user_id : UInt64?
        @source_screen_name : String?
        
        @target_user_id : UInt64?
        @target_screen_name : String?
        
        def initialize(@client : Twitter::Rest::Client, @source_user_id : UInt64, @target_user_id : UInt64)
        end
        
        def initialize(@client : Twitter::Rest::Client, source_identifier : (UInt64|String), target_identifier : (UInt64|String), source_using_user_id? : Bool? = false, target_using_user_id? : Bool? = false)
            if source_using_user_id? || source_identifier.is_a?(UInt64)
                @source_user_id = source_identifier.to_u64
            else
                @source_screen_name = source_identifier.to_s
            end
            
            if target_using_user_id? || target_identifier.is_a?(UInt64)
                @target_user_id = target_identifier.to_u64
            else
                @target_screen_name = target_identifier.to_s
            end
        end
        
        def show()
            endpoint = "friendships/show.json?"
            
            params = {} of String => (String | Nil)
            
            params["source_user_id"] = @source_user_id.to_s if @source_user_id
            params["source_screen_name"] = @source_screen_name if @source_screen_name
            params["target_user_id"] = @target_user_id.to_s if @target_user_id
            params["target_screen_name"] = @target_screen_name if @target_screen_name
            params.compact! # Safekeeping
            
            response = get(endpoint, params)
            
            relationships_parser = JSON::PullParser.new(response.body)
            return Twitter::Response::Relationships.new(relationships_parser).relationship
        end
        
        # TODO: Find a way to refactor this to share code with other requests made
        def get(endpoint, params)
            encoded_params = HTTP::Params.encode(params)
            response = @client.get("https://api.twitter.com/1.1/#{endpoint}#{encoded_params}")
            
            return response
        end
    end
end