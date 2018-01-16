#!/bin/bash

################### USAGE #################
##                                       ##
##   sh danbash.sh tag1 -tag2      ...   ##
##                                       ##
###########################################

################### NOTES #################
##                                       ##
##            Note the -tag2.            ##
##                                       ##
##  This is if you want to exclude a tag ##
##                                       ##
##    For safety, you have to exclude    ##
##             more tags                 ##
##                                       ##
###########################################

################# EXAMPLE #################
##                                       ##
## sh danbash.sh touhou -hat             ##
##                                       ##
##    This will download touhous with    ##
##        no hats and yellow hair        ##
##                                       ##
##      in the directory:                ##
##         touhou+-hat                   ##
##                                       ##
###########################################


# Take every parameter
input="$@"

# Replace spaces with + to fit the URL
tags="${input// /+}"

# Appropriate directory
#   though, if you put the tags in
#   a different way, it will probably
#   re-download the same stuff but in
#   a different directory
mkdir -p "$tags"

echo Leeching everything with: "$tags"
echo Prepare yourself.

# Page number
pid=0

# Loop forever until break
while true; do

    # Display current page number
    #   but will get lost due to wget output
    echo -n "$pid" ' '

    # curls, interprets JSON with jq, uses sed to remove null strings then uses sed to append the address at the beginning of /data/...
    # Then, it uses tee to output to the file so wget can use it.
		get=$(curl -ks "https://donmai.us/posts.json?tags=$tags&page=$pid&limit=100" \
				| jq -r ".[] | .file_url" \
				| sed '/null/d' \
				| sed -e "s/^/https:\/\/donmai.us/" \
				| tee "$tags"/"$tags"image_"$pid".files)


    # Check if the output is alive.
    if [[ ! ${get} ]]; then
        # If the output is empty (empty string)
        #   it will clean and break
        echo Done, no more files
        #echo Cleaning...
        #rm image_*
        break;
    else
        # Downloads the files to an appropriate directory
        wget=$(wget -i "$tags"/"$tags"image_"$pid".files -nc -P "$tags" -c)
        printf "%02d\033[K\r $wget"

        # Increment and continue
        (( pid++ ))
        continue;
    fi

done
