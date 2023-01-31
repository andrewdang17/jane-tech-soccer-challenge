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
```

From file:
```
./main.rb sample-input.txt
```

## Design

<img src="https://user-images.githubusercontent.com/9098711/215679918-0e2ccc46-7c66-4d9e-b59e-9e9e2646be62.png" width=600 />
