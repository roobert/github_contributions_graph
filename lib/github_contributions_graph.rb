#!/usr/bin/env ruby
# encoding=utf-8

require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'yaml'

module GithubContributionsGraph
  def initialize(url:, username: nil, password: nil)
    @url      = url

    @username = username
    @password = password

    validate_auth
  end

  def validate_auth
    return if @username.nil? && @password.nil?
    fail ArgumentError, 'username set but no password set' unless @password
    fail ArgumentError, 'password set but no username set' unless @username
  end

  def doc
    @doc ||= Nokogiri::HTML.parse(data)
             .css('svg.js-calendar-graph-svg')
             .css('g[transform="translate(20, 20)"] g rect.day')
  end

  def data
    if @username && @password
      Github::User::Profile::Calendar::Auth.data(@url, @username, @password)
    else
      Github::User::Profile::Calendar::Plain.data(@url)
    end
  end

  def to_s
    doc.map do |node|
      "#{node['data-date']}: #{node['data-count']}"
    end.join("\n")
  end

  module Auth
    def self.data(url, username, password)
      agent = Mechanize.new
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
    def self.data(url)
      open(url)
    end
  end
end
