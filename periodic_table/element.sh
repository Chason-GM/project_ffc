#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

NOT_FOUND() {
 echo "I could not find that element in the database."
 exit
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[A-Za-z]+$ ]]
  then
    LIST=$($PSQL "select atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from elements inner join properties using(atomic_number) inner join types using(type_id) where elements.name = '$1' or elements.symbol = '$1'")
  elif [[ $1 =~ ^[0-9]+$ ]]
  then
    LIST=$($PSQL "select atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from elements inner join properties using(atomic_number) inner join types using(type_id) where atomic_number = '$1'")
  else
    NOT_FOUND
  fi

  if [[ -z $LIST ]]
  then
    NOT_FOUND
  else
    echo "$LIST" | while IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
    do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ("$SYMBOL"). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."

    done
  fi
  
fi