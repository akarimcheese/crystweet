require "json"
require "http/client"

module Twitter::Response
    struct User
        JSON.mapping({
            id: UInt64,
            id_str: String,
            name: String,
            screen_name: String,
            location: {type: String, nilable: true},
            description: String,
            url: {type: String, nilable: true},
            # entities: TODO,
            protected: Bool,
            verified: Bool,
            followers_count: UInt64,
            following_count: {type: UInt64, key: "friends_count"},
            listed_count: UInt64,
            favourites_count: UInt64,
            tweets_count: {type: UInt64, key: "statuses_count"},
            created_at: String,
            utc_offset: {type: Int32, nilable: true},
            time_zone: {type: String, nilable: true},
            lang: String,
            geo_enabled: Bool,
            is_translator: Bool,
            profile_background_color: {type: String, nilable: true},
            profile_background_image_url: {type: String, nilable: true},
            profile_background_image_url_https: {type: String, nilable: true},
            profile_background_tile: Bool,
            profile_link_color: String,
            profile_sidebar_border_color: String,
            profile_sidebar_fill_color: String,
            profile_text_color: String,
            profile_use_background_image: Bool,
            profile_image_url: String,
            profile_image_url_https: String,
            profile_banner_url: {type: String, nilable: true},
            default_profile: Bool,
            default_profile_image: Bool,
            # Possibly omit
            withheld_in_countries: {type: String, nilable: true},
            withheld_scope: {type: String, nilable: true}
            # TODO:
            # status: TODO as tweet,
            # following: Bool,
            # follow_request_sent: Bool,
            # notifications: Nil
        })
    end
end