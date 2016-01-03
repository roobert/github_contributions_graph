#!/usr/bin/env ruby
#encoding=utf-8

require 'forwardable'

module GithubContributionsGraph
  class Comparer
    attr_accessor :repos

    def initialize
      @repos = Repos.new(YAML.load_file('config.yml')['repos'])
    end

    class Repos
      extend Forwardable

      def initialize(config)
        @repos = load_repos(config)
      end

      def_delegators :@repos, :each, :[]

      def load_repos(config)
        config.keys.each_with_index.map do |repo, index|
          Repo.new(repo, Color.palette(index), config[repo])
        end
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

      def_delegators :@days, :each

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
      attr_accessor :date, :commits

      def initialize(date, commits, palette)
        @date    = date
        @commits = commits
        @palette = palette
      end

      def color
        @color ||= Color.contributions(commits, @palette)
      end

      def ==(other)
        commits == other.commits
      end

      def to_s
        "#{date}: #{commits.ljust(3)} - ##{color.hex}"
      end
    end
  end
end
