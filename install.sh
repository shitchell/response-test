#!/bin/bash

if ! [ $(id -u) = 0 ]; then
	echo "needs moar root"
	exit 1
fi

# Get the script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

INSTALL_DIR=/usr/local/sbin
INSTALL_FILES=(
	console-test
	response-test
	lolsh
)
SHELL_FILES=(
	/etc/profile
	/etc/zsh/zprofile
)

# Setup the default settings
read -p "Challenge phrase: " CHALLENGE
read -sp "Response: " RESPONSE
RESPONSE_HASH="$(echo $RESPONSE | md5sum | awk -F ' ' '{print $1}')"
echo $'\b\b => '$RESPONSE_HASH

# Edit console-test
CHALLENGE=$(echo "$CHALLENGE" | tr -d '"\\')
sed -i "s/CHALLENGE=.*/CHALLENGE=\"$CHALLENGE\"/" console-test
sed -i "s/RESPONSE_HASH=.*/RESPONSE_HASH=\"$RESPONSE_HASH\"/" console-test

# Copy the files to $INSTALL_DIR
for f in "${INSTALL_FILES[@]}"; do
	echo -n "copying $f => "
	cp "$f" $INSTALL_DIR
	echo "$INSTALL_DIR"
done

# Edit the shell files to run console-test
for f in "${SHELL_FILES[@]}"; do
	if [[ -f "$f" ]]; then
		echo echo "$INSTALL_DIR/console-test" '>>' "$f"
		echo "$INSTALL_DIR/console-test" >> "$f"
	fi
done