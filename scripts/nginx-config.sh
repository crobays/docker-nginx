#!/bin/bash

function find_replace_add_string_to_file() {
	find="$1"
	replace="$2"
	replace_escaped="${2//\//\\/}"
	file="$3"
	label="$4"
	if grep -q ";$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
	then
		action="Uncommented"
		sed -i "s/;$find/$replace_escaped/" "$file"
	elif grep -q "#$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
	then
		action="Uncommented"
		sed -i "s/#$find/$replace_escaped/" "$file"
	elif grep -q "$replace" "$file"
	then
		action="Already set"
	elif grep -q "$find" "$file"
	then
		action="Overwritten"
		sed -i "s/$find/$replace_escaped/" "$file"
	else
		action="Added"
		echo -e "\n$replace\n" >> "$file"
	fi
	echo " ==> Setting $label ($action) [$replace in $file]"
}

find_replace_add_string_to_file "daemon .*" "daemon off;" /etc/nginx/nginx.conf "NGINX daemon off"

rm -rf /var/log/nginx
mkdir /var/log/nginx

if [ -f "/project/nginx.conf" ]
then
	ln -sf "/project/nginx.conf" /etc/nginx/nginx.conf
fi

file="/conf/nginx-virtual.conf"
if [ -f "/project/$NGINX_CONF" ]
then
	file="/project/$NGINX_CONF"
fi
rm -rf /etc/nginx/sites-enabled/*
cp -f "$file" /etc/nginx/sites-enabled/virtual.conf

if [ "$SERVE_PATH" ]
then
	mkdir -p "$SERVE_PATH"

	# if [ ! -f "$SERVE_PATH/index.html" ]
	# then
	# 	echo " ==> Creating index.html in $SERVE_PATH"
	# 	echo "<html><head><title>Nginx</title></head><body><h2>You are running NGINX on Docker!</h2></body></html>" > "$SERVE_PATH/index.html"
	# fi
	find_replace_add_string_to_file "root \/.*" "root $SERVE_PATH;" /etc/nginx/sites-enabled/virtual.conf "NGINX public path"
fi

if [ "$ALLOWED" != "all" ]
then
	location="$ALLOWED"
	location="${location/\[/}"
	location="${location/\]/}"
	location="${location//\'/}"
	location="${location//, / }"
	locations=""
	for loc in $location
	do
		locations="$locations\n\tlocation $loc { }\n"
	done
	locations="$locations\n\tlocation / { return 404; }\n"
	find_replace_add_string_to_file "#ALLOWED-LOCATIONS" "$locations" /etc/nginx/sites-enabled/virtual.conf "NGINX public path"
fi

