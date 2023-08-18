PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [ -z "$1" ]
then
  echo "Please provide an element as an argument."
else
  re='^[0-9]+$'
  if [[ $1 =~ $re ]] 
  then
    ELEM=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1;")
    if [ -n "$ELEM" ]
    then
      IFS='|' read -r atom_num symbol name <<< $ELEM
    else
      echo "I could not find that element in the database."
    fi
  else
    ELEM=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$1';")
    if [ -n "$ELEM" ]
    then
      IFS='|' read -r atom_num symbol name <<< $ELEM
    else
      ELEM=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name='$1';")
      if [ -n "$ELEM" ]
      then
        IFS='|' read -r atom_num symbol name <<< $ELEM
      else
        echo "I could not find that element in the database."
      fi
    fi
  fi

  if [ -n "$ELEM" ]
  then
    PROP=$($PSQL "SELECT type_id, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number=$atom_num;")
    IFS='|' read -r typeId atom_mass melt_point boil_point <<< $PROP

    type=$($PSQL "SELECT type FROM types WHERE type_id=$typeId;")
    echo "The element with atomic number $atom_num is $name ($symbol). It's a $type, with a mass of $atom_mass amu. $name has a melting point of $melt_point celsius and a boiling point of $boil_point celsius."
  fi
fi
