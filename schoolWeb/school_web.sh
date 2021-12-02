#!/bin/bash
#Dev By: Terry9A9
#Last Update : 2020-11-30 23:58
#------------------
up=$(echo $1 | tr '[:upper:]' '[:lower:]')
count=0
url="https://www2.hkuspace.hku.hk/cc/programme/higher-diploma"
acquire_target(){
    curl -s $url > ./web.data
    target_url=$(cat web.data | egrep "/cc/higher-diploma/" | cut -d "\"" -f 2 | sed -e 's/.*\/higher-diploma-in-business$//g' | sed -e 's/.*\/marketing$//g')
    echo -n > ./target_url.data
    echo "Acquiring target url from $url ..."
    for acquire_target in $target_url
    do
        echo $acquire_target >> ./target_url.data
    done
    update
}

update(){
    mkdir -p ./programme_source
    echo "Updateing..."
    for update in $target_url
    do
        programme_Name="${update##*/}"
        echo "downloading... $programme_Name"
        curl -s https://www2.hkuspace.hku.hk$update > ./programme_source/$programme_Name.data
    done
    data
}

data(){
    total=$(cat ./target_url.data | wc -l)
    echo -e "\nAcquiring data...\n"
    echo "Division,Programme Code,Programme Name,Phone Number,Fax Number,Contact Email" > ./hd_info.csv
    file=$(cat ./target_url.data)

    for x in $file
    do
        programme_Name="${x##*/}"
        echo "processing... $programme_Name"
        division=$(grep -E "href=\"programme\/" ./programme_source/$programme_Name.data | sed -e 's/<[^>]*>//g' | sed 's/&amp;/and/g' | sed -n 2p | awk '{$1=$1;print}'  )
        code=$(grep -E -o "HD[0-9]{3}" ./programme_source/$programme_Name.data | head -1)
        name=$(grep -E "class=\"prog\""\|"class=\"subj\"" ./programme_source/$programme_Name.data | sed -e 's/<[^>]*>//g' | sed 'N;s/\n/ /' | awk '{$1=$1;print}')
        phone=$(grep -E -o "[0-9]{4} [0-9]{4}( \/ [0-9]{4} [0-9]{4})?" ./programme_source/$programme_Name.data | sed -n 1p)
        fax=$(grep -E -o "[0-9]{4} [0-9]{4}( \/ [0-9]{4} [0-9]{4})?" ./programme_source/$programme_Name.data | sed -n 2p)
        email=$(grep -E -o "h[a-z]*\@[a-z\.]*" ./programme_source/$programme_Name.data | head -1)
        echo "$division,$code,$name,$phone,$fax,$email" >> ./hd_info.csv
        ((count++))
    done
    echo -e "done \nTotal $total HD programme, $count is processed"
}

check(){
case $up in
    "update") acquire_target 
    ;;
    *) data
esac
}

du -sh ./web.data > /dev/null 2>&1
if [ $? -eq 0 ]
then
    check
elif [[ $up == update ]]
then
    acquire_target
else
    echo -e "web.data not found\nplz use \"bash ./ex006q1.sh update\""
    exit 1
fi