#!/bin/bash


TMM_HOME=/home/seamus/apps/tinyMediaManager

movie_dir=/mnt/nas01/new/movie/
jellyfin_url="jellyfin.seamus.vip:8888"
#tvshow_dir=/mnt/nas01/new/tvshow/

movie_id="13d192b95fb72c7248c39e9057670848"
jp_movie_id="5fed72a9e6cd9416a6c38c3db9382302"
us_movie_id="2f7e96c81428e5bddc92557b93bf1386"
#tvshow_id="3227ce1e069754c594af25ea66d69fc7"
api_key="31b965fda61e4a40a80eab2169963270"

http_code=0
down_num=0
diff_line=0

scrape() {
    $TMM_HOME/tinyMediaManager movie -u -n -r
    printf "tmm:%s\n" "$?"
}

refresh() {
    item_id=$1
    http_code=$(curl -i -s -X POST \
        -H "Content-Length: 0" \
        "https://$jellyfin_url/Items/$item_id/Refresh?api_key=$api_key&metadataRefreshMode=Default&imageRefreshMode=Default" \
        | head -n 1| cut -d " " -f 2)
}

check_downloading() {
    check_dir=$1
    down_num=$(ls -R "$check_dir" | grep -c -i -E "xltd|###")
}

check_update() {
    if [ -e "$TMM_HOME"/movies ]
    then
        diff_line=$(diff $TMM_HOME/movies <(ls -R $movie_dir) | wc -l)
    else
        touch "$TMM_HOME"/movies
        diff_line=0
    fi
}

upgrade_list() {
    ls -R $movie_dir > $TMM_HOME/movies
}

main() {
    if [ ! -d $movie_dir ]
    then
        printf "error! %s\n" $movie_dir
        exit 1
    fi
    while true
    do
        check_downloading $movie_dir
        if [ "$down_num" -gt 0 ]
        then
            printf "downloading...\n"
            sleep 1
            continue
        else
            check_update
            if [ "$diff_line" -gt 0 ]
            then
                scrape
                refresh $movie_id
                printf "cn_refresh curl:%s\n" "$http_code"
                refresh $jp_movie_id
                printf "jp_refresh curl:%s\n" "$http_code"
                refresh $us_movie_id
                printf "us_refresh curl:%s\n" "$http_code"
                upgrade_list
            else
                echo "up to date!"
                sleep 2
                continue
            fi
            sleep 5
        fi
    done
}

main
