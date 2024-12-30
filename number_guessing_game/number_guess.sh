#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_GEN=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_TO_USERS=$($PSQL "insert into users(username) values('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
else
  GAME_PLAYED=$($PSQL "SELECT COUNT(user_id) from games where user_id = $USER_ID")
  BEST_GAME=$($PSQL "select min(guesses) from games where user_id = $USER_ID")
  echo -e "\nWelcome back, $USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0

while true
do
  read GUESS
  if [[ $GUESS == $RANDOM_GEN ]]
  then
    (( GUESS_COUNT++ ))
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_GEN. Nice job!"
    INSERT_TO_GAMES=$($PSQL "INSERT INTO games(user_id, guesses) values($USER_ID, $GUESS_COUNT)")
    break
  fi

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
    continue
  else
    if [[ $GUESS -lt $RANDOM_GEN ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
    (( GUESS_COUNT++ ))
    continue
  fi
done




