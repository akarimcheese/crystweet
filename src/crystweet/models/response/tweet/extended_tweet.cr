require "../tweet"

module Twitter::Response
    struct ExtendedTweet
    
        def is_top_level?
            true
        end
        
        def is_nested?
            false
        end
        
        JSON.mapping({
            full_text: String,
            entities: Entities
            
            # TODO:
            # coordinates: Twitter::Coordinates | Nil,
            # current_user_retweet: ??, # Perspectival
            # entities: Twitter::Entities | Nil,
            # place: Twitter::Place | Nil,
            # scopes: ??,
            # truncated: Bool but do we even need to include this,
            # display_text_range: ?? Not in doc but appears in tweets
            # extended_entities: ?? Not in doc
        })
    end
end