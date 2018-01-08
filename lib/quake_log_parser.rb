# Code copied from https://bitbucket.org/lcdss/quake-log-parser
# with some cosmetic adjustments
module QuakeLog
  VERSION = '0.1.1'.freeze
  WORLD_ID = 1022
  MEANS_OF_DEATH = %i[
    MOD_UNKNOWN
    MOD_SHOTGUN
    MOD_GAUNTLET
    MOD_MACHINEGUN
    MOD_GRENADE
    MOD_GRENADE_SPLASH
    MOD_ROCKET
    MOD_ROCKET_SPLASH
    MOD_PLASMA
    MOD_PLASMA_SPLASH
    MOD_RAILGUN
    MOD_LIGHTNING
    MOD_BFG
    MOD_BFG_SPLASH
    MOD_WATER
    MOD_SLIME
    MOD_LAVA
    MOD_CRUSH
    MOD_TELEFRAG
    MOD_FALLING
    MOD_SUICIDE
    MOD_TARGET_LASER
    MOD_TRIGGER_HURT
    MOD_NAIL
    MOD_CHAINGUN
    MOD_PROXIMITY_MINE
    MOD_KAMIKAZE
    MOD_JUICED
    MOD_GRAPPLE
].freeze

  class LogData
    attr_reader :games

    def initialize(games)
      @games = games
    end

    def players
      @games.each_with_object({}) { |g, h| h[g.id] = g.players_name }
    end

    def performance
      @games.each_with_object({}) { |g, h| h[g.id] = g.players_performance }
    end

    def means_of_death
      @games.each_with_object({}) { |g, h| h[g.id] = g.kills_by_means }
    end

    def scoreboards
      @games.each_with_object({}) { |g, h| h[g.id] = g.scoreboard }
    end
  end

  class Parser
    def self.parse(file)
      unless File.exist?(file) && File.readable?(file)
        raise 'The file not exists or cannot be read.'
      end

      games = []
      info = []

      File.readlines(file).each do |line|
        if init_game?(line)
          info = game_info(line)
          games << Game.new(
            games.size,
            start_at: info[:start_at],
            hostname: info[:hostname]
          )
        elsif player_info?(line)
          info = player_info(line)
          player = Player.new(info[:player_id].to_i, info[:player_name])
          games.last.add_player(player)
        elsif kill?(line)
          info = kill_info(line)
          games.last.increment_kills(info[:mean_of_death].to_sym)
          victim = games.last.get_player_by_id(info[:victim_id].to_i)
          if victim.killed_by_world?(info[:killer_id].to_i)
            victim.killed_by_world
          else
            killer = games.last.get_player_by_id(info[:killer_id].to_i)
            victim.killed_by(killer)
          end
        elsif shutdown_game?(line)
          games.last.info[:end_at] = shutdown_game_info(line)[:end_at]
        end
      end

      LogData.new(games)
    end

    def self.init_game?(str)
      !str[/InitGame:/].nil?
    end

    def self.game_info(str)
      str.match(/(?<start_at>\d{1,2}:\d{2}).+(?<=sv_hostname\\)(?<hostname>[\w\s]+[^\\])/)
    end

    def self.kill?(str)
      !str[/Kill:/].nil?
    end

    def self.kill_info(str)
      str.match(/\s(?<killer_id>\d+)\s(?<victim_id>\d+).+(?<mean_of_death>MOD_\w+)/)
    end

    def self.player_info?(str)
      !str[/ClientUserinfoChanged:/].nil?
    end

    def self.player_info(str)
      str.match(/\s(?<player_id>\d+)\sn\\(?<player_name>[\w\s!]+)\\t/)
    end

    def self.shutdown_game?(str)
      !str[/ShutdownGame:/].nil?
    end

    def self.shutdown_game_info(str)
      str.match(/(?<end_at>\d{1,2}:\d{2})/)
    end
  end

  class Game
    attr_reader :id
    attr_accessor :players, :total_kills, :kills_by_means, :info

    def initialize(id, **info)
      @id = id
      @players = []
      @total_kills = 0
      @kills_by_means = {}
      @info = info
    end

    def add_player(player)
      if player?(player)
        get_player_by_id(player.id).name = player.name
      else
        @players << player
      end
    end

    def player?(player)
      @players.map(&:id).include?(player.id)
    end

    def get_player_by_id(player_id)
      @players.detect { |p| p.id == player_id }
    end

    def increment_kills(mean_of_death)
      mean_of_death = :MOD_UNKNOWN unless MEANS_OF_DEATH.include?(mean_of_death)

      if @kills_by_means.key?(mean_of_death)
        @kills_by_means[mean_of_death] += 1
      else
        @kills_by_means[mean_of_death] = 1
      end

      @total_kills += 1
    end

    def players_name
      @players.map(&:name)
    end

    def players_performance
      @players.each_with_object({}) { |p, h| h[p.name] = p.performance }
    end

    def scoreboard
      {
        total_kills: @total_kills,
        players: players_name,
        kills: players_performance,
        kills_by_means: @kills_by_means,
        info: @info
      }
    end
  end

  class Player
    attr_reader :id
    attr_accessor :name, :kills, :deaths

    def initialize(id, name)
      @id = id
      @name = name
      @kills = 0
      @deaths = 0
    end

    def ratio
      @deaths.zero? ? @kills.to_f : (@kills.to_f / @deaths.to_f).round(2)
    end

    def killed_by(player)
      player.kills += 1 unless @id.eql?(player.id)
      @deaths += 1
    end

    def killed_by_world
      @kills -= 1 if @kills > 0
    end

    def killed_by_world?(id)
      id == WORLD_ID
    end

    def performance
      { kills: @kills, deaths: @deaths, ratio: ratio }
    end
  end
end
