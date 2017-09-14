require "json"
require "http/client"

module Twitter::Response
    struct Tweet
        # TODO: populate https://dev.twitter.com/overview/api/tweets
        JSON.mapping({
            id: UInt64,
            created_at: String,
            text: String
        })
    end
end