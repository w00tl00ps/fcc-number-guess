#!/bin/bash

# database connection
PSQL="psql --username=freecodecamp --dbname=number_guess -t  -c"


# generate random number
RANDOM_NUMBER=$((RANDOM % 1000 + 1))
#echo "Random number between 1 and 1000: $RANDOM_NUMBER"

# get user name
echo "Enter your username: "
read USERNAME

# search db for username
USERNAME_DB_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -z $USERNAME_DB_RESULT ]]
then
  # username not found
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # add user to database
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
else
  # user exists, get stats and print welcome message
  USER_STATS=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

  echo "$USER_STATS" | while read GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi


# start guessing game
echo "Guess the secret number between 1 and 1000: "
read GUESS
NUMBER_OF_GUESSES=1

while [[ $GUESS != $RANDOM_NUMBER ]]
do
  # if not integer
  if [[ ! $GUESS =~ [0-9]+ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS > $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  (( NUMBER_OF_GUESSES++ ))
done

# End game message

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

# End game update database
# 1) Increment number of games played
INCREMENT_GAMES_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")
# 2) Update best game
UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME' AND $NUMBER_OF_GUESSES < best_game")
