#!/usr/bin/env ruby
# encoding=utf-8

require "nokogiri"
require "yaml"
require "date"

module GithubContributionsGraph
  class Remote
    def initialize(url:, username: nil, password: nil)
      @url      = url
      @username = username
      @password = password

      validate_auth
    end

    def doc
      @doc ||= Nokogiri::HTML.parse(html)
               .css("svg.js-calendar-graph-svg")
               .css('g[transform="translate(20, 20)"] g rect.day')
    end

    def days
      @days ||= doc.each_with_object({}) do |node, days|
        days[Date.parse(node["data-date"], "%Y-%m-%d")] = node["data-count"]
      end
    end

    def each
      days.each { |day| yield day }
    end

    def to_s
      days.inject([]) { |s, day| s.push "#{day[0]}: #{day[1]}" }.join("\n")
    end

    private

    def validate_auth
      return if @username.nil? && @password.nil?
      raise ArgumentError, "username set but no password set" unless @password
      raise ArgumentError, "password set but no username set" unless @username
    end

    def html
      if @username && @password
        Remote::Login::Auth.data(@url, @username, @password)
      else
        Remote::Login::Plain.data(@url)
      end
    end
  end
end
