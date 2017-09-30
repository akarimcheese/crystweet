require "../*"

module Twitter::Response
    struct NestedTweet < Tweet
        @quoted_tweet : Nil
        @retweeted_tweet : Nil
    
        def is_top_level?
            false
        end
        
        def is_nested?
            true
        end
    
        JSON.mapping({
            id: UInt64,
            id_str: String,
            created_at: String,
            text: String,
            user: Twitter::Response::User,
            favorites_count: {type: Int32, nilable: true},
            retweet_count: Int32,
            lang: {type: String, nilable: true},
            
            # Reply
            in_reply_to_screen_name: {type: String, nilable: true},
            in_reply_to_user_id: {type: UInt64, nilable: true},
            in_reply_to_user_id_str: {type: String, nilable: true},
            in_reply_to_tweet_id: {type: UInt64, nilable: true, key: "in_reply_to_status_id"},
            in_reply_to_tweet_id_str: {type: String, nilable: true, key: "in_reply_to_status_id_str"},
            reply_count: Int32, # Not in doc
            
            # Quoted
            is_quote_tweet: {type: Bool, key: "is_quote_status"}, # Not in doc
            quoted_tweet_id: {type: UInt64, nilable: true, key: "quoted_status_id"},
            quoted_tweet_id_str: {type: String, nilable: true, key: "quoted_status_id_str"},
            quote_count: Int32, # Not in doc
            
            # Perspectival
            favorited: {type: Bool, nilable: true},
            retweeted: {type: Bool, nilable: true},
            
            entities: Entities,
            
            # Possibly omit
            possibly_sensitive: {type: Bool, nilable: true},
            source: {type: String, nilable: true},
            filter_level: {type: String, nilable: true},
            withheld_copyright: {type: Bool, nilable: true},
            withheld_in_countries: {type: Array(String), nilable: true},
            withheld_scope: {type: String, nilable: true}
            
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