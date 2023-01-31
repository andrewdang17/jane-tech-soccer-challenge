class TopTeamsAggregator
  attr_reader :scores

  TEAM_INPUTS_REGEX = /\b\w+ \d+/ # word(s) followed by a space and number
  TIE_POINT = 1
  WIN_POINT = 3

  Team = Struct.new(:name, :score)

  def initialize
    @matchday_number = 1
    @scores = {}
    @top_three_teams = {}
    @games_played = 0
    @number_of_teams = 0
  end

  # @param game_result [String] string containing 2 teams and their score
  #  example: "Santa Cruz Slugs 2, Aptos FC 3"
  def process(game_result)
    return unless game_result.include?(",")

    team_inputs = game_result.split(",").map(&:strip)
    return if invalid_inputs?(team_inputs)

    @games_played += 1
    team1, team2 = get_team_results(team_inputs)

    # since the number of teams in a league is unknown, the end of matchday 1
    # has to be determined by the second matchday when a team plays again.
    # We can then print the previous matchday since we know it has ended.
    if second_matchday?(team1, team2)
      print_results
      @matchday_number = 2
    end

    update_team_scores!(team1, team2)
    update_top_three_teams!(team1, team2)

    if matchday_ended?
      print_results
      reset_matchday!
    end
  end

  def middle_of_matchday?
    # If number_of_teams hasn't been determined and the stream
    # is interrupted before then we want to print the result
    # (see last part of main.rb)
    return true if @number_of_teams.zero?

    @games_played > 1 && !matchday_ended?
  end

  def print_results
    puts "Matchday #{@matchday_number}"

    @top_three_teams.each do |team_name, score|
      puts "#{team_name}, #{score} #{score == 1 ? "pt" : "pts"}"
    end

    print "\n"
  end

  private

  def invalid_inputs?(team_inputs)
    team_inputs.all? { |team_input| !team_input.match(TEAM_INPUTS_REGEX) }
  end

  def get_team_results(team_inputs)
    team_inputs.map do |team_input|
      name, score = team_input.split(/( \d+)/)
      Team.new(name, score)
    end
  end

  def second_matchday?(team1, team2)
    return false if @number_of_teams > 0

    if @scores[team1.name] || @scores[team2.name]
      @number_of_teams = @scores.keys.size
      @games_played = 1
      true
    else
      false
    end
  end

  def update_team_scores!(team1, team2)
    [team1, team2].each do |team|
      @scores[team.name] = 0 if @scores[team.name].nil?
    end

    if team1.score == team2.score
      @scores[team1.name] += TIE_POINT
      @scores[team2.name] += TIE_POINT
    elsif team1.score > team2.score
      @scores[team1.name] += WIN_POINT
    else
      @scores[team2.name] += WIN_POINT
    end
  end

  def update_top_three_teams!(team1, team2)
    scores_to_sort = if @top_three_teams.size < 4
      @scores
    else
      {
        **@top_three_teams,
        team1.name => @scores[team1.name],
        team2.name => @scores[team2.name]
      }
    end

    @top_three_teams = scores.sort_by { |k, v| [-v, k] }.first(3)
  end

  def matchday_ended?
    @number_of_teams / 2 == @games_played
  end

  def reset_matchday!
    @matchday_number += 1
    @games_played = 0
  end
end
