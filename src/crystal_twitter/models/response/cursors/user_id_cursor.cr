require "json"
require "../cursor"

module Twitter::Response
    struct UserIDCursorJSON(T) < Twitter::Response::CursorJSON
        JSON.mapping({
            ids: Array(T),
            next_cursor: UInt64,
            previous_cursor: UInt64,
            next_cursor_str: String,
            previous_cursor_str: String
        })
    end
    
    # Intended for user ids call for now
    class UserIDCursor(T) < Twitter::Response::Cursor(T)
        def get_collection_from(json : CursorJSON) : Array(T)
            json.ids
        end
        
        def from_json(json : JSON::PullParser) : CursorJSON
            UserIDCursorJSON(T).new(json)
        end
        
        # def initialize(twitter_request : Twitter::Request, json : JSON::PullParser)
        #     json = CursorJSON(T).new(json)
            
        #     @twitter_request = twitter_request
        #     @ids = json.ids
        #     @next_cursor = json.next_cursor
        #     @previous_cursor = json.previous_cursor
            
        #     # puts "Prev Cursor: #{@previous_cursor}, String: #{json.previous_cursor_str}"
        #     # puts "Next Cursor: #{@next_cursor}, String: #{json.next_cursor_str}"
            
        #     @index = 0
        #     self
        # end
        
        # Consumes iterator... sorry
        # def to_screen_name_array
        #     screen_names = [] of String
        #     lookup_queue = [] of String
            
        #     each do |id|
        #         lookup_queue << id.to_s
                
        #         if lookup_queue.size == 100
        #             lookup_response =
        #                 Twitter::Request.new(@twitter_request.client, :userLookup, {"user_id" => [lookup_queue.join(",")]})
        #                     .as_post
        #                     .ignore_rate_limit
        #                     .exec
                    
        #             puts lookup_response.body
        #             # Check status code
        #             screen_name_chunk = 
        #                 Array(Twitter::User)
        #                     .new(JSON::PullParser
        #                         .new(lookup_response.body)
        #                     ).map{ |user| user.screen_name }
                    
        #             screen_names.concat(screen_name_chunk)
            
        #             lookup_queue = [] of String
        #         end
        #     end
            
        #     if lookup_queue.size > 0
        #         lookup_response =
        #             Twitter::Request.new(@twitter_request.client, :userLookup, {"user_id" => [lookup_queue.join(",")]})
        #                 .as_post
        #                 .exec
                
        #         # Check status code
        #         screen_name_chunk = 
        #             Array(Twitter::User)
        #                 .new(JSON::PullParser
        #                     .new(lookup_response.body)
        #                 ).map{ |user| user.screen_name }
                
        #         screen_names.concat(screen_name_chunk)
        
        #         lookup_queue = [] of String
        #     end
            
        #     screen_names
        # end
        
    end
end