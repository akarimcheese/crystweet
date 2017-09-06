require "json"
require "http/client"

module Twitter
    struct CursorJSON(T)
        JSON.mapping({
            ids: Array(T),
            next_cursor: UInt64,
            previous_cursor: UInt64,
            next_cursor_str: String,
            previous_cursor_str: String
        })
    end
    
    class Cursor(T)
        include Iterator(T)
        
        property ids, next_cursor, previous_cursor
        property twitter_request, index, sleep_on_limit
        
        @ids : Array(T)
        @next_cursor : UInt64
        @previous_cursor : UInt64
        
        def initialize(twitter_request : Twitter::Request, json : JSON::PullParser)
            json = CursorJSON(T).new(json)
            
            @twitter_request = twitter_request
            @sleep_on_limit = false
            @ids = json.ids
            @next_cursor = json.next_cursor
            @previous_cursor = json.previous_cursor
            
            # puts "Prev Cursor: #{@previous_cursor}, String: #{json.previous_cursor_str}"
            # puts "Next Cursor: #{@next_cursor}, String: #{json.next_cursor_str}"
            
            @index = 0
            self
        end
        
        def sleep_on_rate_limit
            @sleep_on_limit = true
            self
        end
        
        def next
            if !@index || !@twitter_request
                raise "Need to call initialize_with_request()"
                return Iterator::Stop::INSTANCE
            end
            
            if @index == @ids.size
                response = @twitter_request.with_cursor(@next_cursor).exec
                   
                # TODO: Check that this status code is restricted to rate limit errors
                if response.status_code == 429 && @sleep_on_limit
                    sleep(15 * 60 + 5)
                    response = @twitter_request.with_cursor(@next_cursor).exec
                end
                
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