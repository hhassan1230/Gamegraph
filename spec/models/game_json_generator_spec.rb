require 'spec_helper'
require 'open-uri'

def load_json
  path = "../giant_bomb_response.json"
  JSON.load(path)
end
def ratings_response
  final_array = []
  games =["Fallout 3", "Grand Theft Auto IV", "Brütal Legend"]
  games.each do |ze_game|
    if ze_game == "Brütal Legend"
      ze_game = ze_game.gsub("ü", "u")
    end
    orginial_game_name = ze_game
    ign_rating(ze_game)
    
    # unless @response.body.empty?
    #   ratings_hash["#{console}"] ||= []
    #   score = @response.body.first["score"]
    #   ratings_hash["#{console}"] << {"name"=> "#{orginial_game_name}", "size"=> (score.to_i * 10)} 
    # else
    #   ratings_hash["#{console}"] ||= []
    #   ratings_hash["#{console}"] << {"name"=> "#{orginial_game_name}", "size"=> (rand(100...500))} 
    # end
  end
end
def ign_rating(ze_game)
  ze_game = ze_game.gsub(" ", "+")
  @response = Unirest.get "https://videogamesrating.p.mashape.com/get.php?count=1&game=#{ze_game}",
    headers:{
    "X-Mashape-Key" => "RTVHLx6yzRmshJctPcLplL55ghDsp1BdqZzjsnldFcrhBi10ET",
    "Accept" => "application/json"
    }
end
describe GameJsonGenerator do
  let :info_hash {load_json} 
  let :gjg {GameJsonGenerator.new(info_hash)}

  describe "#sort_games" do 
    it "returns an array" do 
      except gjg.sort_games(games_array)
    end
    it "returns an array with the right format" do 

    end
    it "it is sorted correctly" do

    end
  end

end