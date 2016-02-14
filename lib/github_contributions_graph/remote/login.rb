#!/usr/bin/env ruby

require "open-uri"
require "mechanize"

module GithubContributionsGraph
  class Remote
    module Login
      module Auth
        private

        def self.data(url, username, password)
          agent.get(url)
          set_fields(username, password)
          raise StandardError, "login failure" if page.body =~ /Invalid.*login credentials/
          page.body
        rescue => error
          puts "failed to fetch data from url '#{url}': #{error}"
          exit 1
        end

        def self.agent
          @agent ||= Mechanize.new
        end

        def self.form
          @form ||= agent.page.forms.first
        end

        def self.page
          @page ||= form.submit form.buttons.first
        end

        def self.set_fields(username, password)
          form.field_with(name: "login").value    = username
          form.field_with(name: "password").value = password
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
