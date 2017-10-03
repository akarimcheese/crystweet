require "json"
require "http/client"

module Twitter::Response
    struct Relationships
        JSON.mapping({
            relationship: Relationship
        })
    end
    
    struct Relationship
        JSON.mapping({
            source: Relationship::Source,
            target: Relationship::Target
        })
    end
    
    abstract struct Relationship::User
        property id : UInt64
        property id_str : String
        property screen_name : String
        property following : Bool
        property followed_by : Bool
        
        def initialize
            raise "Don't call constructor directly"
        
            @id = 0
            @id_str = "0"
            @screen_name = ""
            @following = false
            @followed_by = false
        end
    end
    
    struct Relationship::Target < Relationship::User
        JSON.mapping({
            id: UInt64,
            id_str: String,
            screen_name: String,
            following: Bool,
            followed_by: Bool,
            following_received: Bool?,
            following_requested: Bool?
        })
    end
    
    struct Relationship::Source < Relationship::User
        JSON.mapping({
            id: UInt64,
            id_str: String,
            screen_name: String,
            following: Bool,
            followed_by: Bool,
            live_following: Bool,
            following_received: Bool?,
            following_requested: Bool?,
            notifications_enabled: Bool?,
            can_dm: Bool,
            blocking: Bool?,
            blocked_by: Bool?,
            muting: Bool?,
            want_retweets: Bool?,
            all_replies: Bool?,
            marked_spam: Bool?
        })
    end
end