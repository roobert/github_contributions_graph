#!/usr/bin/env ruby
#encoding=utf-8

module GithubContributionsGraph
  class Comparer
    attr_accessor :repos

    def initialize
      @repos = Repos.new(config)
    end

    def config
      YAML.load_file('config.yml')['repos']
    end

    class Repos
      def initialize(config)
        @repos = []
        config.keys.each_with_index do |repo, index|
          @repos.push Repo.new(repo, GithubContributionsGraph::Color.palette(index))
        end
      end

      def each
        @repos.each { |repo| yield repo }
      end
    end

    class Repo
      attr_accessor :name, :days

      def initialize(name, palette)
        @name    = name
        @palette = palette
        @days    = Days.new(name, palette)
      end

      def to_s
        "repo: #{@name}"
      end
    end

    class Days
      attr_accessor :days

      def initialize(name, palette)
        @days = []
        load_days(name, palette)
      end

      def each
        @days.each { |day| yield day }
      end

      def load_days(name, palette)
        store(name).each do |date, commits|
          @days.push Day.new(date, commits, palette)
        end
      end

      def store(name)
        @store ||= YAML.load_file("#{name}.yaml")
      end

      def to_s
        result = []
        days.each do |day|
          result << day
        end.join("\n")
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
        @color ||= GithubContributionsGraph::Color.contributions(commits, @palette)
      end

      def to_s
        "#{date}: #{commits} - ##{color.hex}"
      end

      def ==(other)
        commits == other.commits
      end
    end
  end
end
