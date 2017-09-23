module Twitter::Response
    struct Entities
        JSON.mapping({
            hashtags: Array(Hashtag),
            #media: TODO,
            #urls: TODO,
            user_mentions: Array(UserMention)
        })
    end
    
    struct Hashtag
        JSON.mapping({
            text: String,
            indices: Array(Int16)
        })
    end
    
    struct UserMention
        JSON.mapping({
            id: UInt64,
            id_str: String,
            screen_name: String,
            name: String,
            indices: Array(Int16)
        })
    end
end