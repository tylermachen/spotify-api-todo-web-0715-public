describe SpotifyChart do

  describe '#initialize' do
    it "does not raise error when called on with no arguments" do
      expect { SpotifyChart.new }.to_not raise_error
    end

    it "sets a constant 'base_url' as the root url of the Spotify Chart API" do
      expect(SpotifyChart::BASE_URL).to eq("http://charts.spotify.com/api/tracks/most_streamed")
    end
  end

  let(:spotify_chart) { SpotifyChart.new }

  describe "#get_url" do

    it "- accepts one argument, the desired region" do
      expect { spotify_chart.get_url("us") }.to_not raise_error
    end

    let(:gb_most_streamed) { spotify_chart.get_url("gb") }

    it "- returns a string" do
      expect(gb_most_streamed.class).to eq(String)
    end

    it "- returns a string with the base url
      followed by a slash
      then the region
      followed by a slash
      ending with 'weekly/latest'                        " do

      regex = /http:\/\/charts.spotify.com\/api\/tracks\/most_streamed\//
      regex_results = [regex.match(gb_most_streamed), /\/weekly\/latest/.match(gb_most_streamed), /gb/.match(gb_most_streamed)]
      regex_results.each do |match|
        expect(match).to_not be_nil
      end
    end

    it "- returns the correct url for querying the API" do
      expect(gb_most_streamed).to eq("http://charts.spotify.com/api/tracks/most_streamed/gb/weekly/latest")
    end
  
  end

  describe "#get_json" do
    let(:url) { "http://mimeocarlisting.azurewebsites.net/api/cars/1/2" }

    it "accepts one argument, a JSON url" do
      expect { spotify_chart.get_json(url) }.to_not raise_error
    end

    it "returns a hash or an array" do
      type = [Hash, Array]
      expect(spotify_chart.get_json(url).class).to satisfy{|c| type.include?(c)}
    end

    it "is the Ruby Hash version of JSON from a url" do
      expect(spotify_chart.get_json(url)).to eq(JSON.load(open(url)))
    end
  end

  describe "#get_first_track_info" do
     
    let(:us_most_streamed) { JSON.parse( IO.read("spec/support/us_most_streamed.json")) }
    let(:gb_most_streamed) { JSON.parse( IO.read("spec/support/gb_most_streamed.json")) }

    it "accepts one argument, a hash object" do
      expect { spotify_chart.get_first_track_info(us_most_streamed) }.to_not raise_error
    end

    it "returns a string" do
      expect(spotify_chart.get_first_track_info(us_most_streamed).class).to eq(String)
    end

    it "returns <song> by <artist> from the album <album>" do
      expect(spotify_chart.get_first_track_info(us_most_streamed)).to eq("Uptown Funk by Mark Ronson from the album Uptown Funk")
      expect(spotify_chart.get_first_track_info(gb_most_streamed)).to eq("Take Me To Church by Hozier from the album Hozier")      
    end
  end

  describe '#most_streamed' do

    it "accepts one argument, the region" do
      # v subbing out get_json method so that test can predict result v
      class SpotifyChart
        def get_json(arg)
          JSON.parse( IO.read("spec/support/us_most_streamed.json"))
        end
      end
      # ^ subbing out get_json method so that test can predict result ^
      expect { spotify_chart.most_streamed("us") }.to_not raise_error
    end

    it "calls on #get_url, passing it the region" do
      region = "us"
      url = spotify_chart.get_url(region)
      expect(spotify_chart).to receive(:get_url).with(region).and_return(url)
      spotify_chart.most_streamed(region)
    end

    it "passes #get_json the url that #get_url returns" do
      region = "us"
      url = spotify_chart.get_url(region)
      json = spotify_chart.get_json(url)
      expect(spotify_chart).to receive(:get_url).with(region).and_return(url)
      expect(spotify_chart).to receive(:get_json).with(url).and_return(json)
      spotify_chart.most_streamed(region)
    end

    it "passes #get_first_track_info the json that #get_json returns" do
      region = "us"
      url = spotify_chart.get_url(region)
      json = spotify_chart.get_json(url)
      info = spotify_chart.get_first_track_info(json)

      expect(spotify_chart).to receive(:get_url).with(region).and_return(url)
      expect(spotify_chart).to receive(:get_json).with(url).and_return(json)
      expect(spotify_chart).to receive(:get_first_track_info).with(json).and_return(info)
      spotify_chart.most_streamed(region)
    end

    it "returns America's most streamed track title, artist, and album" do
      # v subbing out get_json method so that test can predict result v
      class SpotifyChart
        def get_json(arg)
          JSON.parse( IO.read("spec/support/us_most_streamed.json"))
        end
      end
      # ^ subbing out get_json method so that test can predict result ^
      expect(SpotifyChart.new.most_streamed("us")).to eq("Uptown Funk by Mark Ronson from the album Uptown Funk")
    end

    it "returns Great Britain's most streamed track title, artist, and album" do
      # v subbing out get_json method so that test can predict result v
      class SpotifyChart
        def get_json(arg)
          JSON.parse( IO.read("spec/support/gb_most_streamed.json"))
        end
      end
      # ^ subbing out get_json method so that test can predict result ^
      expect(SpotifyChart.new.most_streamed("gb")).to eq("Take Me To Church by Hozier from the album Hozier")
    end
  end

end