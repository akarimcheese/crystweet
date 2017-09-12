require "json"
require "http/client"

module Twitter::Response
#     # Intended for user ids call for now
#     struct CursorJSON(T)
#         JSON.mapping({
#             collection: {type: T, key: @collection_key}
#             next_cursor: UInt64,
#             previous_cursor: UInt64,
#             next_cursor_str: String,
#             previous_cursor_str: String
#         })
#     end
    abstract struct CursorJSON
    end
    
    # Intended for user ids call for now
    abstract class Cursor(T)
        include Iterator(T)
        
        # property ids, next_cursor, previous_cursor
        # property twitter_request, index
        
        @collection: Array(T) # @ids : Array(T)
        @next_cursor : UInt64
        @previous_cursor : UInt64
        @index : Int32
        @request : Proc(UInt64, HTTP::Client::Response)
        
        def initialize(body : String, @request)
            intermediate_json = from_json(JSON::PullParser.new(body))
            
            @next_cursor = intermediate_json.next_cursor
            @previous_cursor = intermediate_json.previous_cursor
            @collection = get_collection_from(intermediate_json)
            
            @index = 0
        end
        
        private abstract def get_collection_from(intermediate_json : CursorJSON) : Array(T)
        
        abstract def from_json(json : JSON::PullParser) : CursorJSON
        
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
        
        def next_page(cursor)
            @request.call(cursor)
        end
        
        def to_a
            next_cursor = @next_cursor
            
            array = [] of T
            array.concat(@collection)
            
            while next_cursor != 0
                response = next_page(next_cursor)
                
                intermediate_json = from_json(JSON::PullParser.new(response.body))
                next_cursor = intermediate_json.next_cursor
                collection = get_collection_from(intermediate_json)
                array.concat(collection)
            end
            
            return array
        end
        
        def next
            # if !@index || !@twitter_request
            #     raise "Need to call initialize_with_request()"
            #     return Iterator::Stop::INSTANCE
            # end
            
            if @index == @collection.size
                if @next_cursor == 0
                    return Iterator::Stop::INSTANCE
                end
            
                response = next_page(@next_cursor)
                
                # This is kinda redundant in current stage, bc
                # any non-200 will not be returned by client
                if response.status_code != 200
                    # TODO: Return exception instead
                    puts "Response Code: #{response.status_code}, stopped iterating"
                    return Iterator::Stop::INSTANCE
                end
                
                intermediate_json = from_json(JSON::PullParser.new(response.body))
                @index = 0
                @collection = get_collection_from(intermediate_json)
                @previous_cursor = intermediate_json.previous_cursor
                @next_cursor = intermediate_json.next_cursor
                # puts "Prev Cursor: #{@previous_cursor}, String: #{intermediate_json.previous_cursor_str}"
                # puts "Next Cursor: #{@next_cursor}, String: #{intermediate_json.next_cursor_str}"
            end
            
            next_item = @collection[@index]
            @index = @index + 1
            return next_item
        end
    end
end