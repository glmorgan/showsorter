#! /bin/bash

# Author: Glen Morgan
# Date: Jan 2019
# Purpose: Moved completed torrent files to desired media directory to be processed by Plex
LOG_ENABLED=1


TV_SHOW_DIR='TV'
COMPLETED_DIR='completed'
LOG_FILE="showsorter.log"

declare -a groomedKeywords=()

# Array of TV Shows

declare -a TV_SHOWS=("The Big Bang Theory" \
            "America's Got Talent" \
            "Brooklyn Nine Nine" \
            "Chicago Med" \
            "Code Black" \
            "Criminal Minds" \
            "The Blacklist" \
            "The Good Place" \
            "NCIS" \
            "New Amsterdam" \
            "Suits"
            "The Orville" \
            "This Is Us" \
            "9-1-1" \
)

declare -a WORDS_TO_REMOVE=("THE" "IS")

function findDownloadedShow {
    downloadedFile=$1
    
    # Loop through files/directories in completed directory
    for i in "${TV_SHOWS[@]}"
    do
        log "$i"
    
    done
}

function getListOfCompletedDownloads { 
    for download in ${COMPLETED_DIR}/*; do 
        upperDownload="$(tr [a-z] [A-Z] <<< "$download")"
        log "New download detected: $download"
         for show in "${TV_SHOWS[@]}"; do
            keywordGromming "$show"
            hits=0
            for keyword in "${groomedKeywords}"; do
                upperKeyword="$(tr [a-z] [A-Z] <<< "$keyword")"
                if [[ "$upperDownload" =~ "$upperKeyword" ]]; then
                    hits+=1
                fi
                # Determine if the show is a match
                # TODO: Improve this match
                if [[ $hits -gt 0 ]]; then
                    log "Preparing to move $download to $TV_SHOW_DIR/$show"
                    showPath="$TV_SHOW_DIR/$show"
                    
                     # If the directory doesn't exist, create it, then move file/folder
                    if [ ! -d "$showPath" ]; then
                       log "Destination directory does not exist"
                       log "Creating $showPath"
                       mkdir -p "$showPath"                       
                    fi
                    
                    moveFileToFolder "$download" "$showPath/"
                    break
                fi            
            done
         done
    done
   
    
}
# Move a file or directory to a specified location
function moveFileToFolder {
    sourceFile=$1
    destination=$2
    log "Moving $sourceFile to $destination"
     mv "$sourceFile" "$destination/"
    
}

# Remove search terms from show titles for matching Eg. 'The'
function keywordGromming {
    log "Keyword Grooming for show \"$1\""
    serachArray=($1)
    groomedKeywords=()
    for i in "${serachArray[@]}"
    do
        match=0
        for w in "${WORDS_TO_REMOVE[@]}"
        do
            toUpper="$(tr [a-z] [A-Z] <<< "$i")"
            if [ $w == $toUpper ]; then
                match=1    
                break;
            else
                match=0 
            fi
        done
        
        if [[ "$match" -eq 0 ]]; then
            groomedKeywords+=($i)
        fi
    done
}

function log {
    if [[ "$LOG_ENABLED" -eq 1 ]];
    then
        logtime=`date`
        echo "$logtime: $1" >> "$LOG_FILE"
    fi
}

getListOfCompletedDownloads