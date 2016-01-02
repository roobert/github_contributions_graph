#!/usr/bin/env ruby
# encoding=utf-8

require 'yaml'
require 'yaml/store'

module GithubContributionsGraph
  module Database
    def self.update
      repos.each_pair do |name, repo|
        data = GithubContributionsGraph::Calendar.new(
          url:      repo['url'],
          username: repo['username'],
          password: repo['password']
        )

        write(name, data)
      end
    end

    def self.write(name, data)
      store = YAML::Store.new "#{name}.yaml"

      store.transaction do
        data.each do |date, value|
          store[date] = value
        end
      end
    end

    def self.repos
      YAML.load_file('config.yml')['repos']
    end
  end
end
