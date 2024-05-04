#!/bin/bash
set -euo pipefail
REAL_PATH=$(realpath "$0")
W=$(dirname "${REAL_PATH}")

POKEMONS_FOLDER="${W}"/pokemons
PROPERTIES_FILE_SUFFIX="_properties.json"

send_activity_message (){
  message=$1
  echo "$message" > /dev/udp/localhost/9000
}

init_pokemons_folder (){
  if [[ -d "${POKEMONS_FOLDER}" ]]; then
    send_activity_message "The Pokemons folder is already available in ${POKEMONS_FOLDER}"
    return
  fi

  echo "Create Pokemons folder"
  mkdir -p "${POKEMONS_FOLDER}"
}

get_pokemon_properties (){
  pokemon_name=$1
  url=$2
  properties_file=$3

  if [[ -f "$properties_file" ]]; then
    send_activity_message "The properties of $pokemon_name are already available in $properties_file"
    return
  fi

  send_activity_message "Downloading $pokemon_name properties"
  curl -s "$url" > "$properties_file"
}

download_picture (){
  pokemon_folder=$1
  properties_file=$2
  picture_name=$3

  picture_file_name="${pokemon_folder}"/"${picture_name}.png"

  if [[ -f "${picture_file_name}" ]]; then
    send_activity_message "The picture $picture_name is already available in ${picture_file_name}"
    return
  fi

  send_activity_message "Downloading $picture_name"
  # cat "${properties_file}" | jq -r '.sprites["front_default"]'
  picture=$(cat "${properties_file}" | jq --arg picture_name "$picture_name" -r '.sprites[$picture_name]')
  curl -s "$picture" > "$picture_file_name"
}

get_pokemon_pictures (){
  properties_file=$1
  pokemon_folder=$2

  send_activity_message "Downloading $pokemon_name pictures"

  download_picture "$pokemon_folder" "$properties_file" "front_default" 
  download_picture "$pokemon_folder" "$properties_file" "back_default" 
}

get_pokemon (){
  pokemon_name=$1
  url=$2

  POKEMON_FOLDER="${POKEMONS_FOLDER}"/"$pokemon_name"
  send_activity_message "Creating $pokemon_name in $POKEMON_FOLDER"
  mkdir -p "${POKEMON_FOLDER}"
  properties_file="${POKEMON_FOLDER}"/"${pokemon_name}${PROPERTIES_FILE_SUFFIX}"

  get_pokemon_properties "$pokemon_name" "$url" "$properties_file"
  get_pokemon_pictures "$properties_file" "$POKEMON_FOLDER"
}

get_pokemon_list (){
  send_activity_message "Getting pokemon list"
  if [[ -f "${POKEMONS_FOLDER}"/pokemons.json ]]; then
    send_activity_message "The pokemon list is already available in ${POKEMONS_FOLDER}"/pokemons.json
    return
  fi
  curl -s https://pokeapi.co/api/v2/pokemon?limit=12000 | jq > "${POKEMONS_FOLDER}"/pokemons.json
  send_activity_message "the pokemon list is available in ${POKEMONS_FOLDER}"/pokemons.json
}

download_pokemon_list (){
  cat "${POKEMONS_FOLDER}"/pokemons.json | jq -r '.results[] | join(" ")' | while read -r pokemon url; do
    get_pokemon "$pokemon" "$url"
  done
}

init_pokemons_folder

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -l|--list)
      download_pokemon_list
      exit 0
      ;;
    -a|--download-pokemon-list)
      get_pokemon_list
      download_pokemon_list
      exit 0
      ;;
    -p|--download-pokemon)
      POKEMON="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*|*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done
