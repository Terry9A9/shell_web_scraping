#!/bin/bash
up=$(echo $1 | tr '[:upper:]' '[:lower:]')
total=0
url="https://www.lcsd.gov.hk/clpss/en/webApp/Facility/District.do?ftid=42"
urlname=$(echo $url | cut -d "/" -f 3 | tr '.' '_')
acquire_target(){
    curl -s $url > ./$urlname.data
    echo "Acquiring target url from $url..."
    target_url=$(cat ./$urlname.data | grep -Eo "value=\"[0-9]*\""  | sed -e 's/value="*//g' | sed -e 's/["]//g' ) 
    echo -n > ./target_url.data
    for acquire_target in $target_url
    do
        echo "https://www.lcsd.gov.hk/clpss/en/webApp/Facility/Details.do?ftid=42&fcid=&did=$acquire_target" >> ./target_url.data
    done
    update
}

update(){
    mkdir -p ./source
    echo "Updateing..."
    for update in $target_url
    do
        echo "downloading...$update "
        curl -s "https://www.lcsd.gov.hk/clpss/en/webApp/Facility/Details.do?ftid=42&fcid=&did=$update" > ./source/$update.data
    done
    data
}

data(){

    echo -e "\nAcquiring data...\n"
    echo "Name of Venue,Address,Enquiry Phone Number,Number of Courts,Opening Hours" > ./Courts.csv

    for district in $(ls ./source)
    do

        num=$(grep -E  'class=\"table table-bordered table-hover table-striped fac-table\"' ./source/$district | wc -l)
        
        for ((count=1;$count <= $num;count++))
        do
        Name_of_Venue=$(grep -E  "Name of Venue" -A 3 ./source/$district | sed -e 's/<[^>]*>//g' | sed 's/Name of Venue//g'| sed -e 's/--//g' | sed '/^[[:space:]]*$/d' | sed -n ${count}p | awk '{$1=$1;print}' | tr -d '\012\015' )
        Address=$(grep -E  "<b>Address</b>" -A 3 ./source/$district | sed -e 's/<[^>]*>//g' | sed 's/Address//g'| sed -e 's/--//g' | sed '/^[[:space:]]*$/d' | sed 's/,//g' | sed -n ${count}p |awk '{$1=$1;print}' | tr -d '\012\015')
        Enquiry_Phone_Number=$(grep -E  "<b>Enquiry No.</b>" -A 3 ./source/$district | sed -e 's/<[^>]*>//g' | sed 's/Enquiry No.//g'| sed -e 's/--//g' | sed '/^[[:space:]]*$/d' | sed -n ${count}p | awk '{$1=$1;print}' | tr -d '\012\015')
        Number_of_Courts=$(grep -E "Courts No." -A 2 ./source/$district | sed -e 's/<[^>]*>//g' | sed -e 's/--//g' | sed 's/Courts No.//g' | sed 's/,/\//g' | sed '/^[[:space:]]*$/d' | sed -n ${count}p | awk '{$1=$1;print}' | tr -d '\012\015')
        Opening_Hours=$(grep -E "Opening Hours" -A 2 ./source/$district | sed -e 's/<[^>]*>//g' | sed -e 's/--//g' | sed 's/Opening Hours//g' | sed '/^[[:space:]]*$/d' | awk '{$1=$1;print}' | sed -n ${count}p | tr -d '\012\015')
        echo "$Name_of_Venue,$Address,$Enquiry_Phone_Number,$Number_of_Courts,$Opening_Hours" >> ./Courts.csv
        done
        ((total++))
    done
    echo -e "done! $total is processed"
}

check(){
case $up in
    "update") acquire_target 
    ;;
    *) data
esac
}

du -sh ./$urlname.data > /dev/null 2>&1
if [ $? -eq 0 ]
then
    check
elif [[ $up == update ]]
then
    acquire_target
else
    echo -e "$urlname.data not found\nplz use \"bash ./ex006q1.sh update\""
    exit 1
fi