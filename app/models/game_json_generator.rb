class GameJsonGenerator
  attr_reader :game_info_hash
  attr_accessor :formatted_hash, :sorted
  def initialize(game_info_hash)
    @game_info_hash = game_info_hash
    @formatted_hash = {name: "game", children: []}
    generator
  end

  def generator
    consoles_array = get_consoles(game_info_hash)
    Rails.logger.info(consoles_array)
    consoles_n_games = make_games(consoles_array)
    Rails.logger.info(consoles_n_games)
    games_n_ratings = get_games_ratings(consoles_n_games)
    Rails.logger.info(games_n_ratings)
    self.sorted = sort_ratings(games_n_ratings)
    Rails.logger.info(sorted)
    # this should have the ratings and games
  end

  def format_for_d3
    sorted.each do |console, games|
      formatted_hash[:children] << make_consoles(console, games)
    end
    formatted_hash
  end

  def get_consoles(game_json)
    array = []
    game_json["results"].map do |game_hash|
      unless !(game_hash["platforms"])
        game_hash["platforms"].each do |console| 
          array << console["name"]
        end
      end
    end
    (array.uniq - ["PlayStation Network (PS3)", "PlayStation Network (Vita)", "Xbox 360 Games Store", "Wii Shop"])
    # "Mac", "iPad", "Android", "Linux", "Windows Phone", "Browser", "Wii Shop", "Arcade", "iPhone"
  end
  def make_games(consoles_array)
    console_hash = {}
    consoles_array.each do |game_system|
      game_array = place_games(game_system)
      console_hash["#{game_system}"] ||= game_array
    end
    console_hash
  end

  def get_games_ratings(games_hash)
    ratings_hash = {}
    final_ratings_hash = {}
    all_games = games_hash.values.flatten.uniq
    # binding.pry
    all_games.each do |ze_game|
      ign_game_name = ze_game.gsub(" ", "+").gsub("ü", "u").gsub(": Guerrilla","").gsub(" 2: Dog Days","")
      Rails.logger.info(ze_game)
      response = get_ign_data(ign_game_name)
      if response.body.empty? || response.body.first["score"] == 0.0
        score = rand(1..5)
      else
        score = response.body.first["score"]
      end
      ratings_hash[ze_game] = (score.to_f * 10)
    end
    games_hash.each do |console, games|
      games.each do |game|
        game_setup = {"name" => game, "size" => ratings_hash[game]}
        final_ratings_hash[console] ||= []
        final_ratings_hash[console] << game_setup
      end
    end
    final_ratings_hash
  end

  def get_ign_data(game)
    Unirest.get "https://videogamesrating.p.mashape.com/get.php?count=1&game=#{game}",
    headers:{
      "X-Mashape-Key" => "RTVHLx6yzRmshJctPcLplL55ghDsp1BdqZzjsnldFcrhBi10ET",
      "Accept" => "application/json"
      }
  end

  def make_consoles(console, consoles_array)
    # company_hash = {}
      {
        "name"=> console,
        "children"=> [
          {
            name: "great games",
            children: 
              sorted[console][:great_games]
             #great_games(da_console)
          },
          {
            name: "so-so games",
            children: 
              sorted[console][:okay_games]

              # {"name": "game #{(i + 1).to_s}", "size": rand(500...800)},
              # {"name": "other game", "size": rand(500...800)}
            
          },
          {
            name: "weak games",
            children:
              sorted[console][:weak_games]

              # {"name": "sucky game #{i.to_s}", "size": rand(100...500)},
              # {"name": "sucky game #{(i + 2).to_s}", "size": rand(100...500)}
            
          }
        ]
      }
  end

  def place_games(console)
    gamer = []
    @game_info_hash["results"].each do |game_hash|
      in_console = false
      unless !(game_hash["platforms"])
        game_hash["platforms"].each do |platform_hash|
          if platform_hash["name"] == console
            in_console = true
            break
          end
        end  
      end
      if in_console
        gamer << game_hash["name"]
      end
    end 
    gamer
  end

  def sort_ratings(ratings)
    output = {}
    ratings.each do |g_system, c_games_array|
      output[g_system] = {}
      output[g_system][:great_games] = great_games(c_games_array)
      output[g_system][:okay_games] = okay_games(c_games_array)
      output[g_system][:weak_games] = weak_games(c_games_array)

      # output[system] = {name: system, children: {sort_games(c_games_array)}} # {weak_games: [], great_games: []}
      
    end
    output
  end

  def sort_games(games_array)
    output = {weak_games: [], ok_games: [], great_games: []}
    games_array.each do |game_hash|
      game_rating = game_hash["size"]
      case game_rating
        when (0..50)
          output[:weak_games].push(game_hash)
        when (50...80)
          output[:ok_games].push(game_hash)
        when (80..100)
          output[:great_game].push(game_hash)
      end
    end
    output
  end

  def outliers_ign(game)
    # binding.pry
    new_title = game
    new_rating = get_ign_data(new_title)
    if new_rating.body.empty?
      new_rating["body"] = [{"score" => rand(1..5).to_s}]
    elsif new_rating.body.first["score"] == ""
      new_rating.body.first["score"] = rand(1..5).to_s
    end
    # score = rand(1..5)
    # binding.pry
    new_rating
  end

  def great_games(games_array)
    games_by_rating(games_array, 80, 100)
  end

  def okay_games(games_array)
    games_by_rating(games_array, 50, 79.9)
  end

  def weak_games(games_array)
    games_by_rating(games_array, 0, 49.9)
  end

  def games_by_rating(games_array, min, max)
    games_array.select do |game_hash|
      game_hash["size"].to_f.between?(min, max)
    end
  end


end