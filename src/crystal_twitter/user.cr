require "json"
require "http/client"

module Twitter
    struct User
        JSON.mapping({
            created_at: String,
            default_profile: Bool,
            default_profile_image: Bool,
            description: String,
            # entities: TODO,
            favourites_count: UInt64,
            followers_count: UInt64,
            following_count: {type: UInt64, key: "friends_count"},
            geo_enabled: Bool,
            id: Int64,
            is_translator: Bool,
            lang: String,
            listed_count: UInt64,
            location: {type: String, nilable: true},
            name: String,
            profile_background_color: String,
            profile_background_image_url: String,
            profile_background_image_url_https: String,
            profile_background_tile: Bool,
            profile_banner_url: String,
            profile_image_url: String,
            profile_image_url_https: String,
            profile_link_color: String,
            profile_sidebar_border_color: String,
            profile_sidebar_fill_color: String,
            profile_text_color: String,
            profile_use_background_image: Bool,
            protected: Bool,
            screen_name: String,
            # status: TODO,
            tweet_count: {type: UInt64, key: "statuses_count"},
            time_zone: String,
            url: String,
            utc_offset: Int32,
            verified: Bool,
            withheld_in_countries: {type: String, nilable: true},
            withheld_scope: {type: String, nilable: true}
        })
    end
end