require 'json'
require 'open-uri'
require 'pry'

class SpotifyChart
  BASE_URL = "http://charts.spotify.com/api/tracks/most_streamed"

  def get_url(region)
    "#{BASE_URL}/#{region}/weekly/latest"
  end

  def get_json(url)
    JSON.load(open(url))
  end

  def get_first_track_info(music_hash)
    track = music_hash["tracks"].first["track_name"]
    artist = music_hash["tracks"].first["artist_name"]
    album = music_hash["tracks"].first["album_name"]
    "#{track} by #{artist} from the album #{album}"
  end

  def most_streamed(region)
    url = get_url(region)
    hash = get_json(url)
    get_first_track_info(hash)
  end
end
