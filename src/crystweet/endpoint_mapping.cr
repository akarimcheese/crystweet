module Twitter
    class EndpointMapping
        def initialize
            @mapping = {
                :following => "friends/ids.json?",
                :followers => "followers/ids.json?",
                :userSearch => "users/search.json?",
                :userLookup => "users/lookup.json?"
            }
        end
        
        def [](endpoint)
            @mapping[endpoint]
        end
    end
end