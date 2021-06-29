#!/bin/bash

PACKAGE_LOC="../packages/allomorph_requirements.txt"
ACTIVATE_LOC="bin/activate"
USER_VENV_LOC="$HOME/venv/python"

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

function update_venv() {

    section_split "cd $1"
    cd "$1" || exit 1

    if test -f "$ACTIVATE_LOC"; then
        echo "source $ACTIVATE_LOC"
        #shellcheck disable=1090
        source "$ACTIVATE_LOC"

        if test -f "$PACKAGE_LOC"; then
            section_split "pip install -r $PACKAGE_LOC --upgrade --force-reinstall --no-deps"
            pip install -r "$PACKAGE_LOC" --upgrade --force-reinstall --no-deps
        fi

        echo "deactivate"
        deactivate

        section_split "Done with $PWD"
    fi
}

for i in "$USER_VENV_LOC"*; do
    update_venv "$i"
done

for i in "$HOME"/work/micro-allo/*/venv; do
    update_venv "$i"
done
