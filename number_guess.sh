#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#get username
echo "Enter your username:"
read USERNAME
random=$((1+$RANDOM%1000))
count=0
USER=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
if [[ -z $USER ]]
then 
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  #insert new user in database
  INSERT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
  #get new user player id
  USER=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
else
  games_played=$($PSQL "SELECT count(*) FROM games WHERE player_id=$USER")
  best_game=$($PSQL "SELECT min(no_of_guess) FROM games WHERE player_id=$USER")
  username=$($PSQL "SELECT username FROM players WHERE player_id=$USER")
  #Welcome  existing player
  echo Welcome back, $username\! You have played $games_played games, and your best game took $best_game guesses.
fi
echo -e "\nGuess the secret number between 1 and 1000:"
go_to(){
if [[ $1 ]]
then 
  echo -e "$1"
fi
read GUESS
if [[ ! $GUESS =~ ^[0-9]+$ ]]
then
  #count=$(($count+1))
  go_to "That is not an integer, guess again:"
else
  count=$(($count+1))
  if [[ $GUESS -lt $random ]]
  then
    go_to "It's higher than that, guess again:"
  elif [[ $GUESS -gt $random ]]
  then
    go_to "It's lower than that, guess again:" 
  else
    INSERT=$($PSQL "INSERT INTO games(player_id,no_of_guess,secret) VALUES($USER,$count,$random)")
    echo You guessed it in $count tries. The secret number was $random. Nice job\!
  fi
fi
}
go_to 
