#!/usr/bin/env ruby
#encoding=utf-8

require "forwardable"
require "paint"

module GithubContributionsGraph
  class Repos
    extend Forwardable

    def initialize
      @repos = load_repos(config)

      # TODO
      #validate_repos
    end

    def_delegators :@repos, :each, :[], :select

    def load_repos(config)
      config.keys.each_with_index.map do |repo, index|
        # index 0 is intermediate palette
        Repo.new(repo, Color.palette(index + 1), config[repo])
      end
    end

    def config
      YAML.load_file("config.yml")["repos"]
    end
  end

  class Repo
    attr_accessor :name, :days, :palette, :config

    def initialize(name, palette, config)
      @name    = name
      @palette = palette
      @days    = Days.new(name, palette)
      @config  = config
    end

    def to_s
      "repo: #{@name}"
    end
  end

  class Days
    extend Forwardable

    attr_accessor :days

    def initialize(name, palette)
      @days = []
      load_days(name, palette)
    end

    def_delegators :@days, :each, :each_with_index, :length, :[], :first

    def load_days(name, palette)
      store(name).each do |date, commits|
        @days.push Day.new(date, commits, palette)
      end
    end

    def store(name)
      @store ||= YAML.load_file("#{name}.yaml")
    end
  end

  class Day
    attr_accessor :date, :commits, :palette, :winner

    def initialize(date, commits, palette, winner = nil)
      @date    = date
      @commits = commits.to_i
      @palette = palette
      @winner  = winner
    end

    def color
      @color ||= Color.contributions(commits, palette)
    end

    def ==(other)
      commits == other.commits
    end

    def to_s
      Paint["#{date}: #{commits.to_s.ljust(3)} #{winner}", "##{color.hex}"]
    end
  end
end
