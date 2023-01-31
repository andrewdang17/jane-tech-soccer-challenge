## Setup

**Install Gems (install ruby if not yet installed)**

```
bundle install
```

## Running application

Make the script executable:
```
chmod +x main.rb
```

Redirect/pipe from stdin
```
echo "San Jose Earthquakes 3, Santa Cruz Slugs 3
Capitola Seahorses 1, Aptos FC 0
Felton Lumberjacks 2, Monterey United 0
Felton Lumberjacks 1, Aptos FC 2" | ./main.rb

OR

echo "San Jose Earthquakes 3, Santa Cruz Slugs 3
Capitola Seahorses 1, Aptos FC 0
Felton Lumberjacks 2, Monterey United 0
Felton Lumberjacks 1, Aptos FC 2" > input.txt | ./main.rb
```

From file:
```
./main.rb sample-input.txt
```

## Design

<img src="https://user-images.githubusercontent.com/9098711/215679918-0e2ccc46-7c66-4d9e-b59e-9e9e2646be62.png" width=600 />

### Determining Number of Teams in League
- This is explained in [top_teams.rb:28](https://github.com/andrewdang17/jane-tech-soccer-challenge/blob/master/top_teams.rb#L28) but the way I can determine this is by waiting until the 1st game of the 2nd matchday is processed. Because we record scores as games are processed, if a team's score is now being recorded again it can be assumed that they are now playing a different team which means a new matchday has started.

### Determining End of Matchday
- With number of teams determined, we can now tell when the matchday is ended by having a game played counter as game results are processed. The number games is simply the number of teams divided by 2 (two teams per game). Once the counter reaches that number then we can print the end of matchday results and reset the counter.

### Performance

- Game results are recorded in a hash where team name is the key and value is the total score. We could sort this hash by the value (desc) alphabetically each time we need to print the matchday results. To make this more efficient, after a minimum of 3 teams has been recorded, any subsequent game results just need to compare and sort with the top 3 teams (so 5 teams to sort total) instead of re-sorting the entire scores hash again.
- If a file is passed, it can just be read and processed line-by-line using `File.foreach` and avoid loading the entire file in memory.
- Tbh I wasn't sure how to handle a large string input via stdin so I included instructions on writing it to a file first then piping it to the application. I can't imagine pasting a terabyte of data into the command line and didn't want to test the limit in case it crashed my computer.
