class GraphController < ApplicationController
  require 'open-uri'
  require 'uri'
  # require 'unirest'
  def index
  	gaint_bomb_api = "http://www.giantbomb.com/api/games/?api_key=#{ENV["GIANT_KEY"]}&field_list=name%2Cplatforms&format=json&sort=number_of_user_reviews%3Adesc"
  	# json = JSON.parse(open())
  	api = "http://www.giantbomb.com/api/games?api_key=ca6c74e6ef573cb76ea48c4c06d6e47be6cdc13e&format=json&sort=number_of_user_reviews:desc&field_list=name,platforms"
  	game_json = JSON.load(open(api))
    @games_data = game_json
    gjg = GameJsonGenerator.new(@games_data)
    gjg.format_for_d3
    File.open('public/game.json', 'w') { |file| file.write(JSON.dump(gjg.formatted_hash)) }
  	# binding.pry

  	
  	# make_consoles
   #  @super_games_hash = {}
   #  @consoles_array.each do |console|
   #    @super_games_hash["#{console}"] = place_games(console)
   #  end
   #  @super_games_hash.delete("PC")
   #  @super_games_hash.delete("Mac")
   #  @super_games_hash.delete("Linux")
   #  @super_games_hash.delete("Wii Shop")
   #  @super_games_hash.delete("Browser")
   #  @super_games_hash.delete("Windows Phone")
   #  @super_games_hash.delete("iPad")
   #  @super_games_hash.delete("Android")
   #  @ratings = get_games_ratings(@super_games_hash)
   #  # binding.pry
   #  sort_ratings(@ratings)
   #  File.open('public/game.json', 'w') { |file| file.write(@final_hash) }
  end

  def game
  end

 
  def get_games_ratings(games_hash)
    ratings_hash = {}
    ratings_hash.each do |c, array|
      ratings_hash["#{c}"] = []
    end
    games_hash.each do |console, game_array|
      game_array.each do |ze_game|
        @response = get_ign_data(ze_game.gsub(" ", "+").gsub("ü", "u"))

        ratings_hash["#{console}"] ||= []
        if @response.body.empty?
          score = rand(10..50)
        else
          score = @response.body.first["score"]
        end
        ratings_hash["#{console}"] << {"name"=> "#{ze_game}", "size"=> (score.to_f * 10)} 

      end
    end

    ratings_hash
  end

  def get_ign_data(game)
    Unirest.get "https://videogamesrating.p.mashape.com/get.php?count=1&game=#{ze_game}",
        headers:{
        "X-Mashape-Key" => "RTVHLx6yzRmshJctPcLplL55ghDsp1BdqZzjsnldFcrhBi10ET",
        "Accept" => "application/json"
        }
  end

  def make_D3_game_hash(games_hash, console)
    games_hash["#{console}"].
  end

  
  # 	{
  #  "name": "Playstation 3",
  #  "children": [
  #   {
  #    "name": "Great Games",
  #    "children": [
  #     {"name": "God of War", "size": 100},
  #     {"name": "GTA 4", "size": 3812},
  #     {"name": "Mirror Edge", "size": 6714},
  #     {"name": "Star Wars", "size": 743}
  #    ]
  #   },
  #   {
  #   	"name": "Ok Games",
  #   	"children": [
  #   		{"name": "Meh Game", "size": 300},
  #   		{"name": "Other Games", "size": 400}
  #   	]
  #   	},
  #   {
  #    "name": "Sucky Games",
  #    "children": [
  #     {"name": "BetweennessCentrality", "size": 3534},
  #     {"name": "LinkDistance", "size": 5731},
  #     {"name": "MaxFlowMinCut", "size": 7840},
  #     {"name": "ShortestPaths", "size": 5914},
  #     {"name": "SpanningTree", "size": 3416}
  #    ]
  #   }
  #  ]
  # }
  # binding.pry
  end
end
