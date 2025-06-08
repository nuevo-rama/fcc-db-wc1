#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE teams RESTART IDENTITY CASCADE;")
echo $($PSQL "TRUNCATE TABLE games RESTART IDENTITY CASCADE;")

tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do
  if [[ -n "$OPPONENT" ]]; then
    $PSQL \
      "INSERT INTO teams(name)
          SELECT '$OPPONENT'
          WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '$OPPONENT');"
    $PSQL \
      "INSERT INTO teams(name)
          SELECT '$WINNER'
          WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '$WINNER');"
  fi
    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
    echo $OPPONENT_ID
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
    echo $WINNER_ID
  $PSQL \
    "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS');"
done
