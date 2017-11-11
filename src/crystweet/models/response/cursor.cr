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
    abstract class Cursor(T, A)
        include Iterator(T)
        
        # property ids, next_cursor, previous_cursor
        # property twitter_request, index
        
        property collection : Array(T) # @ids : Array(T)
        property inner_index : Int32
        property cum_index : Int32
        property request : Proc(A, HTTP::Client::Response)
        
        def initialize(body : String, @request)
            @collection = [] of T
            
            # @collection should be filled here
            process_json(body) 
            @inner_index = 0
            @cum_index = 0
        end
        
        private abstract def stop? : Bool
        private abstract def next_page : Array(T)
        private abstract def process_json(body : String) : Void
        
        # Consume iterator
        def to_a
            array = [] of T
            array.concat(@collection)
            
            while !stop?
                response = next_page
                
                process_json(response.body)
                array.concat(@collection)
            end
            
            return array
        end
        
        def next
            # if !@index || !@twitter_request
            #     raise "Need to call initialize_with_request()"
            #     return Iterator::Stop::INSTANCE
            # end
            
            if @inner_index == @collection.size
                if stop?
                    return Iterator::Stop::INSTANCE
                end
            
                response = next_page
                
                # This is kinda redundant in current stage, bc
                # any non-200 will not be returned by client
                if response.status_code != 200
                    # TODO: Return exception instead
                    puts "Response Code: #{response.status_code}, stopped iterating"
                    return Iterator::Stop::INSTANCE
                end
                
                @inner_index = 0
                process_json(response.body)
                
                if stop?
                    return Iterator::Stop::INSTANCE
                end
            end
            
            # puts "Collection Size #{@collection.size}, Inner Index #{@inner_index}\n Cum Index #{@cum_index}"
            
            next_item = @collection[@inner_index]
            @inner_index = @inner_index + 1
            @cum_index = @cum_index + 1
            return next_item
        end
    end
end