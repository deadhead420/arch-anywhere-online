#!/bin/bash

config() {

	## Site root hostname
	## This should be set to the ip address or domain of your site
	## (ex: localhost example.org 192.168.1.100)
	host_root="http://arch-anywhere.org"

	## Site root directory on http server
	## This should be set to the path of the root directory of your site
	http_root="/srv/dschacht/arch-anywhere.org/htdocs"

	## Default site paths
	## Do not change these paths unless necessary
	script_dir="$http_root/scripts"
	html_template="$script_dir/html"
	tmphtml="/tmp/index.html"
	tmpinput="/tmp/input.html"
	style="$http_root/styles.css"
	archive="$http_root/news"
	main_index="$http_root/index.html"
	pkg_archive="$http_root/packages"
	pkg_repo="$http_root/repo"
	pkg_link="/repo"

	## Default timestamp format
	timestamp=$(date --rfc-3339='date')
	get_opts "$@"

}

get_opts() {

	case "$1" in
		-a|--article)	if [ -n "$2" ] && [ -f "$2" ]; then
							index_input=$(<"$2" sed 's/^</            </')
						elif [ -n "$2" ]; then
							echo "Error: No such input file '$2'"
							exit 1
						fi
						create_article
		;;
		-p|--package)	if [ -n "$2" ] && [ -f "$2" ] && (<<<"$2" grep ".pkg.tar.xz"); then
							pkg=$(<"$2")	
						elif [ -f "$2" ]; then
							echo "Error: Not a valid package file"
							exit 1
						elif [ -n "$2" ]; then
							echo "Error: No such input file '$2'"
							exit 1
						fi
						pkg_add
		;;
	esac

}

create_article() {

	index_head=$(<"$html_template"/article-head.html)
	index_tail=$(<"$html_template"/article-tail.html)
	echo " Enter a title for the new article"
	echo -n " [title]: "
	read index_title
	link_title=$(<<<"$index_title" sed 's/ /-/g')
	echo -e "\n Name of article author"
	echo -n " [author]: "
	read index_author

	if [ -z "$index_input" ]; then
		echo -e "\n HTML Elements: <p> <h1-h6> <img> <div> <iframe> <ul> <li> <table>"
		echo " CSS inline styling is enabled using style=' '"
		echo " (Note: Article input is created in HTML format)"
		echo -e "\n Create new HTML input file now?"
		echo -n " [y/n]: "
		read input
	fi

	case "$input" in
		y|Y|yes|yy|YY|yY|Yy|Yes|" ")	until [ -n "$EDITOR" ]
										  do
											echo -n " Select a text editor: "
											read EDITOR
											if ! (which $EDITOR &> /dev/null) ; then
												echo -e " Error: Editor $EDITOR not found\n"
												unset EDITOR
											fi
										done
										
										$EDITOR "$tmpinput"
										index_input=$(<"$tmpinput" sed 's/^</            </')
		;;
		*)	exit 1
		;;
	esac

	echo -e "${index_head}<h2>${index_title}</h2>\n<p>Author: ${index_author}</p>\n<p>${timestamp}</p><br>\n${index_input}\n${index_tail}" > "$tmphtml"

	while (true)
	  do
		if [ $(<"$tmphtml" wc -l) -gt "52" ]; then
			echo -e "\n Article: $index_title created successfully!\n What would you like to do now?"
			echo "  1.) View HTML output file"
			echo "  2.) Preview HTML in browser"
			echo "  3.) Publish HTML to host root"
			echo "  4.) Edit HTML input file"
			echo "  5.) Exit without saving changes"
			echo -n "[1,2,3..]: "
			read input
		else
			echo "Error: Failed to create new article"
			exit 1
		fi
    
		case "$input" in
			1)	clear ; cat "$tmphtml"
			;;
			2)	mkdir "$archive"/"$link_title"
				cp "$tmphtml" "$archive"/"$link_title"/index.html
				echo -e "\n You may view the article preview at the following link:\n $host_root/news/$link_title\n\n  1.) Return to menu\n  2.) Publish Changes"
				echo -n " [1,2]: "
				read input

				case $input in
					2)	update_archive
						update_index
						break
					;;
					*)	rm -r "$archive"/"$link_title"
					;;
				esac
			;;
			3)	update_archive
				update_index
				mkdir "$archive"/"$link_title"
                cp "$tmphtml" "$archive"/"$link_title"/index.html
				break
			;;
			4)	$EDITOR "$tmpinput"
				index_input=$(<"$tmpinput" sed 's/^</            </')
				echo -e "${index_head}<h2>${index_title}</h2>\n<p>Author: ${index_author}</p>\n<p>${timestamp}</p><br>\n${index_input}\n${index_tail}" > "$tmphtml"
			;;
			5)	rm "$tmpinput" "$tmphtml" &> /dev/null
				break
			;;
			*)	echo -e "\n Error: Invaild option $input"
			;;
		esac
	done

}	

update_archive() {
	
	index_entries=$(<"$archive"/index.html grep "<tr " | wc -l)
	if [ $((index_entries%2)) -eq 0 ]; then class="even"
	else class="odd"
	fi
	sed -i "/<tbody>/a\\                                    <tr class='$class'>\\
                                            <td>$timestamp</td>\\
                                            <td class='wrap'>\\
                                                    <a href='/news/$link_title' title='$index_title'>\\
                                                    $index_title</a>\\
                                            </td>\\
                                            <td>$index_author</td>\\
                                    </tr>" "$archive"/index.html

}

update_index() {
	
	index_head=$(<"$html_template"/index-head.html)
    index_tail=$(<"$html_template"/index-tail.html)	
	article0=$(<"$main_index" sed '/<h4>/,/<\/div>/!d;/<\/div>/q')
	line_start=$(cat -n "$main_index" | sed '/<h4>/,/<\/div>/!d;/<\/div>/q' | awk 'NR==1 {print $1}')
	line_end=$(cat -n "$main_index" | sed '/<h4>/,/<\/div>/!d;/<\/div>/q' | awk '{print $1}' | tail -n 1)
	article1=$(cat "$main_index" | sed "${line_start},${line_end}d" | sed '/<h4>/,/<\/div>/!d;/<\/div>/q')
	if (<<<"$article1" grep "<h4>Documentation</h4>" &> /dev/null) then unset article1 ; fi
	echo -e "$index_head\n			<h4>
					<a href='/news/$link_title' title='$index_title'>$index_title</a>
				</h4>
				<p class='timestamp'>$timestamp</p>
				<div class='article-content'>
					$index_input
				</div>\n${article0}\n${article1}\n${index_tail}" &> "$main_index"

}

pkg_add() {

	index_head=$(<"$html_template"/package-head.html)
	index_tail=$(<"$html_template"/package-tail.html)
	index_entries=$(<"$pkg_archive"/index.html grep "<tr " | wc -l)
	timestamp=$(date --rfc-3339='date')
	if [ $((index_entries%2)) -eq 0 ]; then class="even"
    else class="odd"
	fi

	echo
	echo -n " Input package name [no spaces]: " ; read pkg_name
	until [ -n "$arch" ]
	  do
		echo -n " Input package architecture [any,i686,x86_64]: " ; read arch
		case "$arch" in
			"i686"|"any"|"Any") pkg_repo="$pkg_repo/i686" pkg_link="$pkg_link/i686" ;;
			"x86_64") pkg_repo="$pkg_repo/x86_64" pkg_link="$pkg_link/x86_64" ;;
			*)	unset arch ; echo -e " Error: Invalid architecture $arch, try again...\n" ;;
		esac
	done
	
	until [ -n "$repo" ]
	  do
		echo -n " Input repository [arch-anywhere,openrc]: " ; read repo
		case "$repo" in
			"arch-anywhere") break ;;
			"openrc") pkg_repo="$pkg_repo/openrc" ;;
			*)	unset repo ; echo -e " Error: Invalid repository $repo, try again...\n" ;;
		esac
	done

	echo -n " Input package description: " ; read desc
	echo -n " Input package license [if unsure use GPL2]: " ; read license
	echo -n " Input package maintainer: " ; read maintainer
	echo -n " Input package version: " ; read version
	echo -n " Input package dependencies [leave blank for none]: " ; read depends
	echo -n " Input package source link [link to source]: " ; read src

	echo -e "\n Review final input:"
	echo " Architecture: $arch"
	echo " Repository: $repo"
	echo " Description: $desc"
	echo " License: $license"
	echo " Maintainer: $maintainer"
	echo " Version: $version"
	echo " Dependencies: $depends"
	echo " Source Link: $src"
	echo -e "\n Continue with adding package?"
	echo -n " [y/n]: " ; read input

	while (true)
	  do
		case "$input" in
			y|Y|yy|YY|yes|Yes|yY|Yy|" ") pkg_upload ; break ;;
			n|N|nn|NN|no|No|nN|Nn)	pkg_add ; break ;;
			*) 	echo -e " Error: Invalid input $input, try again...\n Continue with adding package?"
				echo -n " [y/n]: " ; read input ;;
		esac
	done

}

pkg_upload() {

	until [ -n "$pkg" ]
	  do
		echo -n " Input package file (This can be a path or link)[.pkg.tar.xz]: " ; read pkg
		if [ -f "$pkg" ] && (<<<"$pkg" grep ".pkg.tar.xz"); then
			cp "$pkg" "$pkg_repo"
		elif (<<<"$pkg" grep "ftp://\|http://\|https://" &> /dev/null) && (<<<"$pkg" grep ".pkg.tar.xz"); then
			wget -O "$pkg_repo"/ "$pkg"
		else
			echo -e " Error: Package file $pkg not found, try again...\n" ; unset pkg
		fi
	done

	pkg=$(<<<"$pkg" sed 's:^.*/::g')

	if [ "$repo" == "openrc" ]; then
		repo-add -R "$pkg_repo"/openrc.db.tar.gz "$pkg"
	else
		case "$arch" in
			any|Any) 	cd "$http_root"/repo/i686
						repo-add -R arch-anywhere.db.tar.gz "$pkg"
						cp "$pkg" "$http_root"/repo/x86_64
						cd "$http_root"/repo/x86_64
						repo-add -R arch-anywhere.db.tar.gz "$pkg"
			;;
			*)	cd "$pkg_repo"
				repo-add -R arch-anywhere.db.tar.gz "$pkg"
			;;
		esac
	fi
	
	echo "$index_head" > "$tmphtml"
	echo "<h2>$pkg_name</h2>
		<div id='detailslinks' class='listing'>
			<div id='actionlist'>
				<h4>Package Actions</h4>
					<ul class='small'>
						<li><a href='$src' target="_blank">Source Files</a></li>
						<li><a href='$pkg_link/$pkg'>Download From Mirror</a></li>
					</ul>
			</div>
		</div>
		<table id='pkginfo'>
			<tr>
				<th>Architecture: </th>
				<td>$arch</td>
			</tr>
			<tr>
            	<th>Repository: </th>
            	<td>$repo</td>
            </tr>
			<tr>
            	<th>Description: </th>
            	<td>$desc</td>
            </tr>
			<tr>
            	<th>License: </th>
            	<td>$license</td>
            </tr>
			<tr>
            	<th>Maintainer: </th>
                <td>$maintainer</td>
            </tr>
			<tr>
				<th>Version: </th>
				<td>$version</td>
			</tr>
			<tr>
                <th>Size: </th>
                <td>0.2 KB</td>
            </tr>
			<tr>
                <th>Updated: </th>
                <td>$timestamp</td>
            </tr>
            <tr>
				<th>Dependencies: </th>
				<td>$depends</td>
            </tr>
		</table>" >> "$tmphtml"
	echo "$index_tail" >> "$tmphtml"
	while (true)
	  do
		if [ $(<"$tmphtml" wc -l) -gt "52" ]; then
			echo -e "\n Package: $pkg_name created successfully!\n What would you like to do now?"
			echo "  1.) View HTML output file"
			echo "  2.) Preview HTML in browser"
			echo "  3.) Publish HTML to host root"
			echo "  4.) Edit HTML input file"
			echo "  5.) Exit without saving changes"
			echo -n "[1,2,3..]: "
			read input
		else
			echo "Error: Failed to create new article"
			exit 1
		fi
    
		case "$input" in
			1)	clear ; cat "$tmphtml"
			;;
			2)	mkdir "$pkg_archive"/"$pkg_name"
				cp "$tmphtml" "$pkg_archive"/"$pkg_name"/index.html
				echo -e "\n You may view the package preview at the following link:\n $host_root/packages/$pkg_name\n\n  1.) Return to menu\n  2.) Publish Changes"
				echo -n " [1,2]: "
				read input

				case $input in
					2)	update_pkg_archive ; break
					;;
					*)	rm -r "$pkg_archive"/"$pkg_name"
					;;
				esac
			;;
			3)	mkdir "$pkg_archive"/"$pkg_name"
                cp "$tmphtml" "$pkg_archive"/"$pkg_name"/index.html
				update_pkg_archive ; break
			;;
			4)	$EDITOR "$tmpinput"
				index_input=$(<"$tmpinput" sed 's/^</            </')
				echo -e "${index_head}\n<h4>${index_title}</h4>\n${index_input}\n${index_tail}" > "$tmphtml"
			;;
			5)	rm "$tmpinput" "$tmphtml" &> /dev/null
				break
			;;
			*)	echo -e "\n Error: Invaild option $input"
			;;
		esac
	done

}

update_pkg_archive() {

	index_head=$(<"$html_template"/pkg-archive-head.html)
	index_tail=$(<"$html_template"/pkg-archive-tail.html)
	cd "$pkg_archive"
	rm index.html
	pkg_int=1
	for file in *; do
		ver=$(<"$file"/index.html grep -A1 "Version" | sed '1d;s,<td>,,;s,</td>,,;s/^[ \t]*//')
		des=$(<"$file"/index.html grep -A1 "Description" | sed '1d;s,<td>,,;s,</td>,,;s/^[ \t]*//')
		maintain=$(<"$file"/index.html grep -A1 "Maintainer" | sed '1d;s,<td>,,;s,</td>,,;s/^[ \t]*//')
		timest=$(<"$file"/index.html grep -A1 "Updated" | sed '1d;s,<td>,,;s,</td>,,;s/^[ \t]*//')
		if [ $((pkg_int%2)) -eq 0 ]; then
			class="even"
		else
			class="odd"
		fi
		pkg_array="$pkg_array<tr class='$class'>\n<td><a href='/packages/$file'>$file</a></td>\n<td>$ver</td>\n<td>$des</td>\n<td>$maintain</td>\n<td>$timest</td>\n</tr>\n"
		pkg_int=$((pkg_int+1))
	done

	echo -e "$index_head\n$pkg_array\n$index_tail" > "$pkg_archive"/index.html

}

config "$@"
