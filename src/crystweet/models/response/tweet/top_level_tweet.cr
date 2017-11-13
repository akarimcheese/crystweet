require "../tweet"
require "./*"

module Twitter::Response
    struct TopLevelTweet < Twitter::Response::Tweet
        def self.extended_new_while_streaming(parser : JSON::PullParser)
            tweet = self.new(parser)
            
            if (extended_tweet = tweet.extended_tweet)
                tweet.text = extended_tweet.full_text
                tweet.entities = extended_tweet.entities
                # @extended_entities = extended_tweet.extended_entities
                # TODO: Extend nested tweet if that's an issue
            end
            
            tweet
        end
        
        def self.extended_new(parser : JSON::PullParser)
            tweet = self.new(parser)
            tweet.extend_text
        end
        
        def extend_text
            if (full_text = @full_text)
                @text = full_text
                if (nested_tweet = @retweeted_tweet)
                    @retweeted_tweet = nested_tweet.extend_text
                end
                if (nested_tweet =  @quoted_tweet)
                    @quoted_tweet = nested_tweet.extend_text
                end
            end
            
            self
        end
    
        def is_top_level?
            true
        end
        
        def is_nested?
            false
        end
        
        JSON.mapping({
            id: UInt64,
            id_str: String,
            created_at: String,
            text: {type: String, default: ""},
            user: Twitter::Response::User,
            favorites_count: {type: Int32, nilable: true},
            retweet_count: Int32,
            retweeted_tweet: {type: NestedTweet, nilable: true, key: "retweeted_status"},
            lang: {type: String, nilable: true},
            
            full_text: {type: String, nilable: true},
            extended_tweet: {type: ExtendedTweet, nilable: true},
            
            # Reply
            in_reply_to_screen_name: {type: String, nilable: true},
            in_reply_to_user_id: {type: UInt64, nilable: true},
            in_reply_to_user_id_str: {type: String, nilable: true},
            in_reply_to_tweet_id: {type: UInt64, nilable: true, key: "in_reply_to_status_id"},
            in_reply_to_tweet_id_str: {type: String, nilable: true, key: "in_reply_to_status_id_str"},
            reply_count: {type: Int32, nilable: true}, # Not in doc
            
            # Quoted
            is_quote_tweet: {type: Bool, key: "is_quote_status"}, # Not in doc
            quoted_tweet_id: {type: UInt64, nilable: true, key: "quoted_status_id"},
            quoted_tweet_id_str: {type: String, nilable: true, key: "quoted_status_id_str"},
            quoted_tweet: {type: NestedTweet, nilable: true, key: "quoted_status"},
            quote_count: {type: Int32, nilable: true}, # Not in doc
            
            # Perspectival
            favorited: {type: Bool, nilable: true},
            retweeted: {type: Bool, nilable: true},
            
            entities: Entities,
            # Entities
            # hashtags: {type: Array(String), root: "entities"},
            # urls: {type: Array(String), root: "entities"},
            # user_mentions: {type: Array(String), root: "entities"},
            # symbols
            # media : id, id_str, indices ?int array, media_url, media_url_https, url, display_url, expanded_url,... there's a lot
            
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