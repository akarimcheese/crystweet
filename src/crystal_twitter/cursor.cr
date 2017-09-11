require "json"
require "http/client"

module Twitter
    # Intended for user ids call for now
    struct CursorJSON(T)
        JSON.mapping({
            ids: Array(T),
            next_cursor: UInt64,
            previous_cursor: UInt64,
            next_cursor_str: String,
            previous_cursor_str: String
        })
    end
    
    # Intended for user ids call for now
    class Cursor(T)
        include Iterator(T)
        
        property ids, next_cursor, previous_cursor
        property twitter_request, index
        
        @ids : Array(T)
        @next_cursor : UInt64
        @previous_cursor : UInt64
        
        def initialize(twitter_request : Twitter::Request, json : JSON::PullParser)
            json = CursorJSON(T).new(json)
            
            @twitter_request = twitter_request
            @ids = json.ids
            @next_cursor = json.next_cursor
            @previous_cursor = json.previous_cursor
            
            # puts "Prev Cursor: #{@previous_cursor}, String: #{json.previous_cursor_str}"
            # puts "Next Cursor: #{@next_cursor}, String: #{json.next_cursor_str}"
            
            @index = 0
            self
        end
        
        # Consumes iterator... sorry
        def to_screen_name_array
            screen_names = [] of String
            lookup_queue = [] of String
            
            each do |id|
                lookup_queue << id.to_s
                
                if lookup_queue.size == 100
                    lookup_response =
                        Twitter::Request.new(@twitter_request.client, :userLookup, {"user_id" => [lookup_queue.join(",")]})
                            .as_post
                            .ignore_rate_limit
                            .exec
                    
                    puts lookup_response.body
                    # Check status code
                    screen_name_chunk = 
                        Array(Twitter::User)
                            .new(JSON::PullParser
                                .new(lookup_response.body)
                            ).map{ |user| user.screen_name }
                    
                    screen_names.concat(screen_name_chunk)
            
                    lookup_queue = [] of String
                end
            end
            
            if lookup_queue.size > 0
                lookup_response =
                    Twitter::Request.new(@twitter_request.client, :userLookup, {"user_id" => [lookup_queue.join(",")]})
                        .as_post
                        .exec
                
                # Check status code
                screen_name_chunk = 
                    Array(Twitter::User)
                        .new(JSON::PullParser
                            .new(lookup_response.body)
                        ).map{ |user| user.screen_name }
                
                screen_names.concat(screen_name_chunk)
        
                lookup_queue = [] of String
            end
            
            screen_names
        end
        
        def next
            if !@index || !@twitter_request
                raise "Need to call initialize_with_request()"
                return Iterator::Stop::INSTANCE
            end
            
            if @index == @ids.size
                if @next_cursor == 0
                    return Iterator::Stop::INSTANCE
                end
            
                response = 
                    @twitter_request.with_cursor(@next_cursor)
                        .ignore_rate_limit
                        .exec
                
                if response.status_code != 200
                    # TODO: Return exception instead
                    puts "Response Code: #{response.status_code}, stopped iterating"
                    return Iterator::Stop::INSTANCE
                end
                
                next_page = CursorJSON(T).new(JSON::PullParser.new(response.body))
                @index = 0
                @ids = next_page.ids
                @previous_cursor = next_page.previous_cursor
                @next_cursor = next_page.next_cursor
                # puts "Prev Cursor: #{@previous_cursor}, String: #{next_page.previous_cursor_str}"
                # puts "Next Cursor: #{@next_cursor}, String: #{next_page.next_cursor_str}"
            end
            
            next_id = @ids[@index]
            @index = @index + 1
            return next_id
        end
    end
end