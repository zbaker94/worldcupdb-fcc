#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


file_path="games.csv"

teams=$(cat "$file_path" | tail -n +2 | awk -F',' '{print $3 "\n" $4}' | sort | uniq)

IFS=$'\n' read -d '' -r -a team_array <<< "$teams"



for team in "${team_array[@]}"; do
  $PSQL "INSERT INTO teams (name) VALUES ('$team') ON CONFLICT (name) DO NOTHING;"
done

while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  if [ "$year" != "year" ]; then
    echo "Year: $year"
    echo "Round: $round"
    echo "Winner: $winner"
    echo "Opponent: $opponent"
    echo "Winner Goals: $winner_goals"
    echo "Opponent Goals: $opponent_goals"
    echo "---------------------"
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, opponent_goals, winner_goals) VALUES ($year, '$round', (SELECT team_id FROM teams WHERE name='$winner'),(SELECT team_id FROM teams WHERE name='$opponent'), $opponent_goals, $winner_goals);"
  fi
done < "$file_path"
