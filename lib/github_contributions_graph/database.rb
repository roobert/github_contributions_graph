#!/usr/bin/env ruby
# encoding=utf-8

require 'yaml'
require 'yaml/store'

module GithubContributionsGraph
  module Database
    def self.update
      repos.each_pair do |name, repo|
        days = GithubContributionsGraph::Calendar.new(
          url:      repo['url'],
          username: repo['username'],
          password: repo['password']
        )

        write(name, days)
      end
    end

    def self.write(name, days)
      store = YAML::Store.new "#{name}.yaml"

      store.transaction do
        days.each { |day, commits| store[day] = commits }
      end
    end

    def self.repos
      YAML.load_file('config.yml')['repos']
    end
  end
end
