#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# ingresar nombre
echo "Enter your username:"
read NAME
PLAYER_NAME=$($PSQL "SELECT player_name FROM games WHERE player_name ='$NAME'")
# ya jugo antes?
if [[ -z $PLAYER_NAME ]]
then
  # darlo de alta y saludarlo
  INSERT=$($PSQL "INSERT INTO games(player_name) VALUES ('$NAME')")
  echo "Welcome, "$NAME"! It looks like this is your first time here."
  GAMES_P=0
else
  # recupera cantidad y score
  GAMES_P=$($PSQL "SELECT games_played FROM games WHERE player_name='$NAME'")
  BEST_G=$($PSQL "SELECT best_game FROM games WHERE player_name='$NAME'")
  # Saluda al jugador
  echo "Welcome back, "$PLAYER_NAME"! You have played "$GAMES_P" games, and your best game took "$BEST_G" guesses."
fi
# iniciar el juego
NUMBER=$((RANDOM%1000+1))
echo $NUMBER
echo "Guess the secret number between 1 and 1000:"
EXIT=0
ACUM=0
until [ $EXIT -eq 1 ]
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:" 
    ACUM=$((ACUM+1))
    else  
    if [ $GUESS -lt $NUMBER ]
    then
      echo "It's higher than that, guess again:"
      ACUM=$((ACUM+1))
    elif [ $GUESS -gt $NUMBER ]
    then
      echo "It's lower than that, guess again:"
      ACUM=$((ACUM+1))
    else
      ACUM=$((ACUM+1))
      EXIT=1
    fi
  fi
done
# guardar el score al finalizar
if [ $GAMES_P -eq 0 ]
then
  GAMES_P=1
  BEST_G=$ACUM
else
  GAMES_P=$((GAMES_P+1))
  if [ $BEST_G -gt $ACUM ]
  then
    BEST_G=$ACUM
  fi
fi
UPDATE=$($PSQL "UPDATE games SET games_played=$GAMES_P WHERE player_name='$NAME'")
UPDATE=$($PSQL "UPDATE games SET best_game=$BEST_G WHERE player_name='$NAME'")
echo "You guessed it in "$ACUM" tries. The secret number was "$NUMBER". Nice job!"

