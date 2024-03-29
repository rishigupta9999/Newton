class LinkTo < ActiveRecord::Base
  def get_type_id_string
    LinkTo.type_id_to_string(self.type_id)
  end

  def self.get_type_name_to_id_array
    pairs = Array.new
    5.times do |i|
      pair = [LinkTo.type_id_to_string(i), i]
      pairs << pair
    end
    return pairs
  end

  def self.type_id_to_string(type_id)
    case type_id
    when LinkTo.standard_type
        return "Standard LinkTo" #Link to youtube, FB, etc...
    #special meaning (ToDos)
    when LinkTo.sync_spotify_type
        return "Sync Spotify info"
    when LinkTo.party_invitation_type
        return "New party invitation"
    when LinkTo.invite_friend_type
        return "Invite a friend to party"
    when LinkTo.request_to_join_party_type
        return "Request to join party"
    else
        return "UNKNOW"
    end
  end

  #tells you if the linkto is currently in a user action
  def is_currently_unassigned
    return (UserAction.where( :action_id => self.id ).empty? == true)
  end

  #IDs for specific types of LinkTos
  def self.standard_type
    return 0
  end

  def self.sync_spotify_type
    return 1
  end

  def self.party_invitation_type
    return 2
  end

  def self.invite_friend_type
    return 3
  end

  def self.request_to_join_party_type
    return 4
  end

  def is_standard_linkto
     return (self.type_id == LinkTo.standard_type)
  end

  def is_youtube_embedded_video_linkto
     return (self.type_id == LinkTo.standard_type) && ((self.url.include? "youtube.com") && (self.url.include? "embed"))
  end

  def youtube_video_id
    components = self.url.split("/")
    videoId = components[components.length - 1]

    return videoId
  end

  def is_tweet_linkto
     return (self.type_id == LinkTo.standard_type) && (self.url.include? "twitter.com")
  end

  #query spacial linktos (nil if the linkto is not persent in the database)
  def self.get_sync_spotify_link
    return LinkTo.where("type_id = " + LinkTo.sync_spotify_type.to_s ).first
  end

  def self.get_party_invitation_link
    return LinkTo.where("type_id = " + LinkTo.party_invitation_type.to_s ).first
  end

  def self.get_invite_friend_link
    return LinkTo.where("type_id = " + LinkTo.invite_friend_type.to_s ).first
  end

  def self.get_request_to_join_party_link
    return LinkTo.where("type_id = " + LinkTo.request_to_join_party_type.to_s ).first
  end

end
