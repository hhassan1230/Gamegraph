class GraphController < ApplicationController
  require 'open-uri'
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
  	# binding.pry
    
    @consoles_array.each do |console|

    end
    File.open('public/game.json', 'w') { |file| file.write(@final_hash) }
  end

  def game
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
    @games_data["results"].each do |game_hash|
      # binding.pry
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
      # iterate through each game
      # see if the game belongs to current console
      # if game belongs put game name in hash with score from ign api 

    end 
    binding.pry
  end
  def make_consoles
    company_hash = {}
    @consoles_array.each do |da_console|
      i = 0
  		@final_hash["children"] << {
  			"name": da_console,
  			"children": [
  				{
  					"name": "great games",
  					"children": [
              # put iterated game 
  						{"name": "game #{i.to_s}", "size": rand(800..1000)},
  						{"name": "game #{i.to_s}", "size": rand(800..1000)}
  					]
  				},
          {
            "name": "so-so games",
            "children": [
              {"name": "game #{(i + 1).to_s}", "size": rand(500...800)},
              {"name": "other game", "size": rand(500...800)}
            ]
          },
          {
            "name": "weak games",
            "children": [
              {"name": "sucky game #{i.to_s}", "size": rand(100...500)},
              {"name": "sucky game #{(i + 2).to_s}", "size": rand(100...500)}
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
