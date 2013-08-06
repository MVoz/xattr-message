#!/bin/bash
#set -e

FILE_NAME="$1"
XATTR_NOTE="user.note"
XATTR_VALUE=$(getfattr -n $XATTR_NOTE --only-values "$FILE_NAME")
err=$?
if [ $err != 0 ]; then
	gxmessage -title "Note:error" "getfattr error $err"
	exit $err
fi
#echo "XATTR_VALUE: $XATTR_VALUE"
#XATTR_VALUE=$(echo "$XATTR_VALUE" | sed -rn 's/^'$XATTR_NOTE'="([^"]*)"$/\1/p')
echo "XATTR_VALUE: $XATTR_VALUE"

TMP=$(mktemp)

gxmessage \
	-title "Note" \
	-buttons "okay:0,Cancel:67" \
	-entrytext "$XATTR_VALUE" \
	"${XATTR_VALUE}" >$TMP
GUI_ERR=$?
XATTR_VALUE=$(cat $TMP)
echo "XATTR_VALUE: $XATTR_VALUE"
if (( GUI_ERR == 0 )); then
	setfattr -n $XATTR_NOTE -v "$XATTR_VALUE" "$FILE_NAME" 2>$TMP
	err=$?
	if [ $err != 0 ]; then
		gxmessage -title "Note:error" "setfattr error $err $(cat $TMP)"
		exit $err
	fi
fi

rm --force $TMP
