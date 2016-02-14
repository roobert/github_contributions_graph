#!/usr/bin/env ruby

$LOAD_PATH.unshift("lib")

require "github_contributions_graph"

GithubContributionsGraph::Database.update
repos = GithubContributionsGraph::Repos.new

repo_public = repos.select { |repo| repo.name == "public" }[0]
repo_work   = repos.select { |repo| repo.name == "work" }[0]

if repo_public.days.length != repo_work.days.length
  raise StandardError, "contributions contain different amount of days"
end

merged = []

repo_public.days.each_with_index do |public_day, index|
  work_day = repo_work.days[index]

  total_commits = public_day.commits + work_day.commits

  mix_palette = GithubContributionsGraph::Color.palette(0)

  if public_day.commits == work_day.commits
    palette = mix_palette
    winner = :none
  end

  if public_day.commits > 0 && work_day.commits > 0
    palette = mix_palette
    winner = :mix
  end

  if public_day.commits == 0 && work_day.commits > 0
    palette = work_day.palette
    winner = :work
  end

  if work_day.commits == 0 && public_day.commits > 0
    palette = public_day.palette
    winner = :public
  end

  merged << GithubContributionsGraph::Day.new(public_day.date, total_commits, palette, winner)
end

merged.each do |day|
  puts day
end
