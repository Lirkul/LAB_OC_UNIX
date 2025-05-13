#!/bin/bash

SHARED_DIR="/shared_data"
LOCK_FILE="$SHARED_DIR/.lockfile"
CONTAINER_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
COUNTER=1

mkdir -p "$SHARED_DIR"


create_file() {
    (
        flock -x 200

        for i in $(seq -w 1 999); do
            if [ ! -f "$SHARED_DIR/$i" ]; then
                echo "$i"
                return
            fi
        done
        echo ""
    ) 200>"$LOCK_FILE"
}

while true; do

    FILE_NAME=$(create_file)
    
    if [ -n "$FILE_NAME" ]; then

        echo "Container: $CONTAINER_ID, File number: $COUNTER" > "$SHARED_DIR/$FILE_NAME"
        COUNTER=$((COUNTER + 1))


        sleep 1


        (
            flock -x 200
            rm -f "$SHARED_DIR/$FILE_NAME"
        ) 200>"$LOCK_FILE"
    fi


    sleep 1
done