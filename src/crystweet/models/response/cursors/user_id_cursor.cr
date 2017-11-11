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
    class UserIDCursor(T) < Twitter::Response::Cursor(T, UInt64)
        property next_cursor : UInt64
        property previous_cursor : UInt64
        
        def initialize(body : String, @request)
            @next_cursor = 0
            @previous_cursor = 0
            
            # next and previous cursor initialized here
            super(body, @request) 
        end
    
        def get_collection_from(json : CursorJSON) : Array(T)
            json.ids
        end
        
        def from_json(json : JSON::PullParser) : CursorJSON
            UserIDCursorJSON(T).new(json)
        end
        
        def stop?
            @next_cursor == 0
        end
        
        def next_page
            @request.call(@next_cursor)
        end
        
        def process_json(json)
            intermediate_json = from_json(JSON::PullParser.new(json))
            @collection = get_collection_from(intermediate_json)
            @previous_cursor = intermediate_json.previous_cursor
            @next_cursor = intermediate_json.next_cursor
        end
    end
end