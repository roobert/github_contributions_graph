#!/usr/bin/env ruby
#encoding=utf-8

require 'open-uri'
require 'mechanize'

module GithubContributionsGraph
  class Calendar
    module Login
      module Auth
        private

        def self.agent
          @agent ||= Mechanize.new
        end

        def self.data(url, username, password)
          page = agent.get(url)
          form = agent.page.forms.first
          form.field_with(name: 'login').value = username
          form.field_with(name: 'password').value = password
          page = form.submit form.buttons.first
          page.body
        rescue => error
          puts "failed to fetch data from url '#{url}': #{error}"
          exit 1
        end
      end

      module Plain
        private

        def self.data(url)
          open(url)
        end
      end
    end
  end
end
