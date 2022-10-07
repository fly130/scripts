#!/bin/bash

# Copyright (c)2022 https://bookfere.com
# This is a batch script for fixing Google Translate and making it available
# in the Chinese mainland. If you experience any problem, visit the page below:
# https://bookfere.com/post/1020.html

SOURCE_DOMAIN=google.cn
TARGET_DOMAIN=translate.googleapis.com
HOSTS_FILE=/etc/hosts

HOST_CMD=/usr/bin/host
CUT_CMD=/usr/bin/cut
SED_CMD=/usr/bin/sed

IP=$($HOST_CMD -t A $SOURCE_DOMAIN | $CUT_CMD -d ' ' -f 4)
OLD_RULE=$(cat $HOSTS_FILE | grep $TARGET_DOMAIN)
NEW_RULE="$IP $TARGET_DOMAIN"
COMMENT="# Fix Google Translate CN"

if [ -n "$OLD_RULE" ]; then
    echo "A rule has been added to the hosts file. "
    echo "[1] Update [2] Delete"
    echo -n "Enter a number to choose an action: "
    read action
    if [ "$action" == "1" ]; then
        if [ "$OLD_RULE" != "$NEW_RULE" ]; then
            echo "Deleting the rule \"$OLD_RULE\""
            echo "Adding the rule \"$NEW_RULE\""
            $SED_CMD -i '' "s/.*${TARGET_DOMAIN}/${NEW_RULE}/" $HOSTS_FILE
        else
            echo 'The rule already exists, nothing to do.'
        fi
    fi
    if [ "$action" == "2" ]; then
        echo "Deleting the rule \"$OLD_RULE\""
        PATTERN="s/\n\{0,\}${COMMENT}\n.* ${TARGET_DOMAIN}//"
        $SED_CMD -i '' -e ':a' -e 'N' -e '$!ba' -e "$PATTERN" $HOSTS_FILE
    fi
else
    echo "Adding the rule \"$NEW_RULE\""
    echo -ne "\n${COMMENT}\n${NEW_RULE}" >> $HOSTS_FILE
fi

echo 'Done.'
