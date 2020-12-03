#!/bin/bash

TMPD="$(mktemp -d)"
cp /config/motion.conf "$TMPD/motion.conf"

while IFS= read -r -d $'\0' PAIR; do
	# Check only for MOTION_ envvars
	[[ $PAIR == MOTION_* ]] || continue

	# Do ONE split on PAIR
	IFS=$'\n' read -d "" -ra PARTS <<<"${PAIR/=/$'\n'}"
	KEY="${PARTS[0]}"
	VALUE="${PARTS[1]}"

	# Strip motion prefix
	KEY="${KEY#MOTION_}"

	# Lowercase KEY
	KEY="${KEY,,}"

	printf "Setting motion parameter '%s' => '%s'\n" "$KEY" "$VALUE"
	printf "%s %s\n" "$KEY" "$VALUE" >>"$TMPD/motion.conf"

	# sed -E "s|^$KEY\s+.*|$KEY $VALUE|" \
	# 	>"$TMPD/motion.conf.tmp" <"$TMPD/motion.conf" &&
	# 	mv "$TMPD/motion.conf.tmp" "$TMPD/motion.conf"
done < <(cat /proc/self/environ)

exec /usr/bin/tini -s /usr/bin/motion -- -c "$TMPD/motion.conf"
