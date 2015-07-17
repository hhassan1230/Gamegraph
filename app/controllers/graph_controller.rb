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
  	@consoles_array = get_consoles(game_json)
    @consoles_array.delete("PlayStation Network (PS3)")
    @consoles_array.delete("PlayStation Network (Vita)")
    @consoles_array.delete("Xbox 360 Games Store")
  	@final_hash = {}
  	@final_hash["name"] = "game"
  	@final_hash["children"] = []
  	make_consoles
    @super_games_hash = {}
    @consoles_array.each do |console|
      @super_games_hash["#{console}"] = place_games(console)
    end
    @super_games_hash.delete("PC")
    @super_games_hash.delete("Mac")
    @super_games_hash.delete("Linux")
    @super_games_hash.delete("Wii Shop")
    @super_games_hash.delete("Browser")
    @super_games_hash.delete("Windows Phone")
    @super_games_hash.delete("iPad")
    @super_games_hash.delete("Android")
    @ratings = get_games_ratings(@super_games_hash)
    # binding.pry
    sort_ratings(@ratings)
    File.open('public/game.json', 'w') { |file| file.write(@final_hash) }
  end

  def game
  end

  def sort_ratings(ratings)
    binding.pry
    
  end
  def get_games_ratings(games_hash)
    ratings_hash = {}
    ratings_hash.each do |c, array|
      ratings_hash["#{c}"] = []
    end
    games_hash.each do |console, game_array|
      game_array.each do |ze_game|
        if ze_game == "Brütal Legend"
          ze_game = ze_game.gsub("ü", "u")
        end
        orginial_game_name = ze_game
        ze_game = ze_game.gsub(" ", "+")
        @response = Unirest.get "https://videogamesrating.p.mashape.com/get.php?count=1&game=#{ze_game}",
        headers:{
        "X-Mashape-Key" => "RTVHLx6yzRmshJctPcLplL55ghDsp1BdqZzjsnldFcrhBi10ET",
        "Accept" => "application/json"
        }
        unless @response.body.empty?
          ratings_hash["#{console}"] ||= []
          score = @response.body.first["score"]
          ratings_hash["#{console}"] << {"name"=> "#{orginial_game_name}", "size"=> (score.to_i * 10)} 
        else
          ratings_hash["#{console}"] ||= []
          ratings_hash["#{console}"] << {"name"=> "#{orginial_game_name}", "size"=> (rand(100...500))} 
        end
      end
    end
    ratings_hash
  end

  def get_consoles(game_json)
  	array = []
  	game_json["results"].map do |game_hash|
  		game_hash["platforms"].each do |console| 
  			array << console["name"]
  		end
  	end
  		array.uniq
  end

  def place_games(console)
    gamer = []
    @games_data["results"].each do |game_hash|
      in_console = false
      game_hash["platforms"].each do |platform_hash|
        if platform_hash["name"] == console
          in_console = true
          break
        end
      end
      if in_console
        gamer << game_hash["name"]
      end
    end 
    gamer
  end

  def make_consoles
    company_hash = {}
    @consoles_array.each do |da_console|
      i = 0
  		@final_hash["children"] << {
  			"name"=> da_console,
  			"children"=> [
  				{
  					"name": "great games",
  					"children"=> [
              # put iterated game 
  						# {"name": "game #{i.to_s}", "size": rand(800..1000)},
  						# {"name": "game #{i.to_s}", "size": rand(800..1000)}
  					]
  				},
          {
            "name": "so-so games",
            "children"=> [
              # {"name": "game #{(i + 1).to_s}", "size": rand(500...800)},
              # {"name": "other game", "size": rand(500...800)}
            ]
          },
          {
            "name": "weak games",
            "children"=> [
              # {"name": "sucky game #{i.to_s}", "size": rand(100...500)},
              # {"name": "sucky game #{(i + 2).to_s}", "size": rand(100...500)}
            ]
          }
  			]
  		}
  		i += 1
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
