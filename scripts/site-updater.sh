#!/bin/bash

init() {
	
	### Site variables
	web_iso=/srv/dschacht/arch-anywhere.org/htdocs/iso/
#	index_file=~/arch-anywhere.org/htdocs/index.html
#	download_file=~/arch-anywhere.org/htdocs/download.html

	### Define variables
	anywhere_version=$(ls ~/arch-linux-anywhere | grep -e 'arch-anywhere-.*.iso' | tail -n1)
	anywhere_iso=~/arch-linux-anywhere/"$anywhere_version"
	anywhere_checksum=~/arch-linux-anywhere/arch-anywhere-checksums.txt

	iso_update

}


iso_update() {

#	echo -n "Would you like to update the direct download ISO now? [y/N]:"
#	read input

#	case "$input" in
#		y|Y|yes|Yes|yY|Yy|yy|YY)
#			cp "$anywhere_iso" "$web_iso"
#			sed -ie "s/Arch Anywhere latest direct download:.*/Arch Anywhere latest direct download: <a href=\"iso\\/$anywhere_version\">$anywhere_version<\/a><br>/" "$download_file"
			
#			if [ ! -f "$anywhere_checksums" ]; then
#				echo
#				echo "Generating ISO checksums..."
#				md5_sum=$(md5sum "$anywhere_version" | awk '{print $1}')
#				sha1_sum=$(sha1sum "$anywhere_version" | awk '{print $1}')
#				timestamp=$(timedatectl | grep "Universal" | awk '{print $4" "$5" "$6}')
#				echo -e "- Arch Anywhere is licensed under GPL v2\n- Developer: Dylan Schacht (deadhead3492@gmail.com)\n- Webpage: http://arch-anywhere.org\n- ISO timestamp: $timestamp\n- $anywhere_version Official Check Sums:\n\n* md5sum: $md5_sum\n* sha1sum: $sha1_sum" > ~/web_iso/arch-anywhere-checksums.txt
#				echo "Checksums generated successfully"
#			else
#	cp "$anywhere_checksums" "$web_iso"
#			fi
#		;;
#	esac

	echo -n "Would you like to create a new torrent now? [y/N]:"
	read input

	case "$input" in
		y|Y|yes|Yes|yY|Yy|yy|YY)
			cd "$web_iso"

			if [ -f "$anywhere_version".torrent ]; then
				rm "$anywhere_version".torrent
			fi

			mktorrent -a "udp://tracker.openbittorrent.com:80" -a "udp://tracker.leechers-paradise.org:6969" -a "udp://tracker.coppersurfer.tk:6969" -a "udp://glotorrents.pw:6969" -a "udp://tracker.opentrackr.org:1337" -a "http://linuxtracker.org:2710/announce" -c "$anywhere_version - A live Arch Linux installer ISO http://arch-anywhere.org" -v -w "http://arch-anywhere.org/iso/$anywhere_version" "$anywhere_version"
#			sed -ie "s/Arch Anywhere latest torrent:.*/Arch Anywhere latest torrent: <a href=\"iso\\/$anywhere_version.torrent\">$anywhere_version.torrent<\/a><br>/" "$download_file"
		;;
	esac

}

init
