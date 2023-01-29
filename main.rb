#!/usr/bin/env ruby

require_relative "./top_teams"

if !ARGV[0] && $stdin.tty?
  puts "No file or text input was passed. Please try again."
  return
end

top_teams = TopTeams.new

if ARGV[0]
  File.foreach(ARGV[0]) do |game_result|
    top_teams.process(game_result)
  end
else
  $stdin.read.chomp.split("\n").each do |game_result|
    top_teams.process(game_result)
  end
end
