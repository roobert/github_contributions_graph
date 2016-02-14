#!/usr/bin/env ruby

# grimey test nonsense..

$LOAD_PATH.unshift("lib")

require "gruff"
require "github_contributions_graph"
require "awesome_print"

GithubContributionsGraph::Database.update
repos = GithubContributionsGraph::Repos.new

repo_public = repos.select { |repo| repo.name == "public" }[0]
repo_work   = repos.select { |repo| repo.name == "work" }[0]

repo_public_days = repo_public.days.map { |day| day.commits }
repo_work_days   = repo_work.days.map   { |day| day.commits }

dataset = [
  [:public, repo_public_days[0..100]],
  [:work,   repo_work_days[0..100]]
]

graph = Gruff::StackedBar.new("12000x3000")

labels = {}

repo_public.days.each.with_index.each_with_object(labels) do |(day, index), labels|
  labels[index] = day.date.to_s
end

labels = labels.delete_if { |k, v| k > 200 }

graph.labels = labels

dataset.each do |data|
  graph.data(data[0], data[1])
end

graph.marker_font_size = 1
graph.theme = {
  colors:            ["#aedaa9", "#12a702"],
  marker_color:      "#dddddd",
  font_color:        "black",
  background_colors: "white"
}

graph.write("test.png")
