#!/bin/bash

init() {

	### Set the location of the access log here
	log=/srv/dschacht/logs/arch-anywhere.access.log

	### Locations of HTML pages with counters
	index_file=/srv/dschacht/arch-anywhere.org/htdocs/index.html
	download_file=/srv/dschacht/arch-anywhere.org/htdocs/download.html
	image_file=/srv/dschacht/arch-anywhere.org/htdocs/gallery.html
	features_file=/srv/dschacht/arch-anywhere.org/htdocs/features.html
	video_file=/srv/dschacht/arch-anywhere.org/htdocs/videos.html

	### Define date value
#	day=$(date +%D)
#	utc_time=$(date --utc +%H:%M)

#	if [ "$day" -ne "$prev_day" ]; then
#		daily_log
#	fi

	### Define hit value variables from access log
	day=$(date | awk '{print $3"."$2"."$6}')
	prev_day="$day"
	as_of=$(date)
	unique_date=$(awk '/'$day'/ {print $1}' < "$log" | sort | uniq | wc -l)
	total_date=$(< "$log" grep "$day" | wc -l)
	total_unique=$(awk '{print $1}' < "$log" | sort | uniq | wc -l)
	total_hits=$(< "$log" wc -l)
	total_unique=$((total_unique+12671))
	total_hits=$((total_hits+1922773))

	echo_hits

}

echo_hits() {

	echo -e "\n ${Yellow}Todays date: ${Green}$day\n"
	echo " ${Yellow}Total hits today: ${Green}$total_date"
	echo -e " ${Yellow}Total unique hits today: ${Green}${unique_date}\n"
	echo " ${Yellow}Total site hits: ${Green}$total_hits"
	echo " ${Yellow}Total unique site hits: ${Green}$total_unique${ColorOff}"
}

#write_counter() {

#	until [ "$day" != "$prev_day" ]
#	  do
#		sed -i "s/Unique Page Views:.*/Unique Page Views: <b>$total_unique<\/b><\/p>/;s/Total Page Hits:.*/Total Page Hits: <b>$total_hits<\/b><\/p>/;s/Hit Counter As Of:.*/Hit Counter As Of: <b>$as_of<\/b><\/p>/" "$index_file"
#		sed -i "s/Unique Page Views:.*/Unique Page Views: <b>$total_unique<\/b><\/p>/;s/Total Page Hits:.*/Total Page Hits: <b>$total_hits<\/b><\/p>/;s/Hit Counter As Of:.*/Hit Counter As Of: <b>$as_of<\/b><\/p>/" "$download_file"
#		sed -i "s/Unique Page Views:.*/Unique Page Views: <b>$total_unique<\/b><\/p>/;s/Total Page Hits:.*/Total Page Hits: <b>$total_hits<\/b><\/p>/;s/Hit Counter As Of:.*/Hit Counter As Of: <b>$as_of<\/b><\/p>/" "$image_file"
#		sed -i "s/Unique Page Views:.*/Unique Page Views: <b>$total_unique<\/b><\/p>/;s/Total Page Hits:.*/Total Page Hits: <b>$total_hits<\/b><\/p>/;s/Hit Counter As Of:.*/Hit Counter As Of: <b>$as_of<\/b><\/p>/" "$features_file"
#		sed -i "s/Unique Page Views:.*/Unique Page Views: <b>$total_unique<\/b><\/p>/;s/Total Page Hits:.*/Total Page Hits: <b>$total_hits<\/b><\/p>/;s/Hit Counter As Of:.*/Hit Counter As Of: <b>$as_of<\/b><\/p>/" "$video_file"
#		sleep 600
#		day=$(date | awk '{print $3"."$2"."$6}')
#	done

#}

#daily_log() {

#	prev_log=~/logs/arch-anywhere.${prev_day}access.log
#	mv "$log" "$prev_log"
	


	

#}
init
