#!/usr/bin/env ruby

require_relative "./top_teams_aggregator"

if !ARGV[0] && $stdin.tty?
  puts "No file or text input was passed. Please try again."
  return
end

top_teams_aggregator = TopTeamsAggregator.new

if ARGV[0]
  File.foreach(ARGV[0]) do |game_result|
    top_teams_aggregator.process(game_result)
  end
else
  $stdin.read.chomp.split("\n").each do |game_result|
    top_teams_aggregator.process(game_result)
  end
end

# matchday considered ended in case of an interrupted stream
if top_teams_aggregator.middle_of_matchday?
  top_teams_aggregator.print_results
end
