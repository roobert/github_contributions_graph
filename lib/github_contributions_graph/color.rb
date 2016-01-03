#!/usr/bin/env ruby
#encoding=utf-8

require 'paleta'

module GithubContributionsGraph
  module Color
    # FIXME: at the moment, only support comparing two graphs..
    PALETTES = [
      '#1e6823',
      '#481e68',
      '#681e3e'
    ]

    def self.contributions(commits, palette)
      case commits.to_i
      when 0                  then palette[0]
      when 1..24              then palette[1]
      when 25..49             then palette[2]
      when 50..74             then palette[3]
      when commits.to_i >= 75 then palette[4]
      else
        fail StandardError, "invalid input for number of commits: #{commits}"
      end
    end

    def self.palette(index)
      Paleta::Palette.generate(
        type: :shades,
        from: :color,
        size: 5,
        color: Paleta::Color.new(:hex, PALETTES[index])
      )
    end
  end
end
