require "rspec"
require "pathname"
require_relative "../top_teams_aggregator"

describe TopTeamsAggregator do
  let(:top_teams_aggregator) { TopTeamsAggregator.new }
  let(:matchday1_game1_result) { "San Jose Earthquakes 3, Santa Cruz Slugs 3" }
  let(:matchday1_game2_result) { "Capitola Seahorses 1, Aptos FC 0" }
  let(:matchday1_game3_result) { "Felton Lumberjacks 2, Monterey United 0" }
  let(:matchday2_game1_result) { "Felton Lumberjacks 1, Aptos FC 2" }

  context "when processing first game of matchday 1" do
    subject { top_teams_aggregator.process(matchday1_game1_result) }

    it "records score but outputs nothing" do
      expect(top_teams_aggregator).to_not receive(:print_results)
      subject
      expect(top_teams_aggregator.scores).to eq({
        "San Jose Earthquakes"=>1,
        "Santa Cruz Slugs"=>1
      })
    end
  end

  context "when processing all games of matchday 1" do
    subject do
      top_teams_aggregator.process(matchday1_game1_result)
      top_teams_aggregator.process(matchday1_game2_result)
      top_teams_aggregator.process(matchday1_game3_result)
    end

    it "records scores but outputs nothing" do
      expect(top_teams_aggregator).to_not receive(:print_results)
      subject
      expect(top_teams_aggregator.scores).to eq({
        "Aptos FC" => 0,
        "Capitola Seahorses" => 3,
        "Felton Lumberjacks" => 3,
        "Monterey United" => 0,
        "San Jose Earthquakes"=>1,
        "Santa Cruz Slugs"=>1
      })
    end
  end

  context "when processing first game of matchday 2" do
    let(:matchday_results) do
      <<~EOS
        Matchday 1
        Capitola Seahorses, 3 pts
        Felton Lumberjacks, 3 pts
        San Jose Earthquakes, 1 pt

      EOS
    end

    before do
      top_teams_aggregator.process(matchday1_game1_result)
      top_teams_aggregator.process(matchday1_game2_result)
      top_teams_aggregator.process(matchday1_game3_result)
    end

    subject { top_teams_aggregator.process(matchday2_game1_result) }

    it "records scores and prints top 3 teams for matchday 1" do
      expect { subject }.to output(matchday_results).to_stdout
      expect(top_teams_aggregator.scores).to eq({
        "Aptos FC" => 3,
        "Capitola Seahorses" => 3,
        "Felton Lumberjacks" => 3,
        "Monterey United" => 0,
        "San Jose Earthquakes" => 1,
        "Santa Cruz Slugs" => 1
      })
    end
  end

  context "when processing multiple matchday game results" do
    let(:root) { Pathname.new(File.dirname(__FILE__)) }
    let(:sample_input_txt) { File.open(root.join("../sample-input.txt")) }

    # could use the expected-output txt file but formatting and \n were causing issues
    let(:expected_output) do
      <<~EOS
        Matchday 1
        Capitola Seahorses, 3 pts
        Felton Lumberjacks, 3 pts
        San Jose Earthquakes, 1 pt

        Matchday 2
        Capitola Seahorses, 4 pts
        Aptos FC, 3 pts
        Felton Lumberjacks, 3 pts

        Matchday 3
        Aptos FC, 6 pts
        Felton Lumberjacks, 6 pts
        Monterey United, 6 pts

        Matchday 4
        Aptos FC, 9 pts
        Felton Lumberjacks, 7 pts
        Monterey United, 6 pts

      EOS
    end

    subject do
      File.foreach(sample_input_txt) do |game_result|
        top_teams_aggregator.process(game_result)
      end
    end

    it "prints top 3 teams for each matchday" do
      expect { subject }.to output(expected_output).to_stdout
    end
  end

  context "when invalid game result is passed" do
    let(:invalid_game_result) { "this wont work" }

    it "does nothing" do
      top_teams_aggregator.process(invalid_game_result)
      expect(top_teams_aggregator.scores).to eq({})
    end
  end

  describe "#middle_of_matchday" do
    subject { top_teams_aggregator.middle_of_matchday? }

    context "when playing first game of matchday" do
      before do
        top_teams_aggregator.process(matchday1_game1_result)
      end

      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "when playing middle of matchday" do
      before do
        top_teams_aggregator.process(matchday1_game1_result)
        top_teams_aggregator.process(matchday1_game2_result)
      end

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when playing last game of matchday" do
      before do
        top_teams_aggregator.process(matchday1_game1_result)
        top_teams_aggregator.process(matchday1_game2_result)
        top_teams_aggregator.process(matchday1_game3_result)
        top_teams_aggregator.process(matchday2_game1_result)
        top_teams_aggregator.process("Santa Cruz Slugs 0, Capitola Seahorses 0")
        top_teams_aggregator.process("Monterey United 4, San Jose Earthquakes 2")
      end

      it "returns false" do
        expect(subject).to eq false
      end
    end
  end
end
