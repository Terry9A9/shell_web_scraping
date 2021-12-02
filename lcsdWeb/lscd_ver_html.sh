#!/bin/bash
up=$(echo $1 | tr '[:upper:]' '[:lower:]')
total=0
url="https://www.lcsd.gov.hk/clpss/en/webApp/Facility/District.do?ftid=42"
urlname=$(echo $url | cut -d "/" -f 3 | tr '.' '_')
html=lcsd.html
echo -n "" > $html
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

    echo "<!doctype html>" >> $html
    echo "<html lang=\"en\">" >> $html
    echo "  <head>" >> $html
    echo "    <!-- Required meta tags -->" >> $html
    echo "    <meta charset=\"utf-8\">" >> $html
    echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" >> $html
    echo "" >> $html
    echo "    <!-- Bootstrap CSS -->" >> $html
    echo "    <link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-giJF6kkoqNQ00vy+HMDP7azOuL0xtbfIcaT9wjKHr8RbDVddVHyTfAAsrekwKmP1\" crossorigin=\"anonymous\">" >> $html
    echo "" >> $html
    #html body content
    echo "    <table class=\"table-info\">" >> $html
    echo "        <thead>" >> $html
    echo "          <tr>" >> $html
    echo "            <th scope=\"col\">Name of Venue</th>" >> $html
    echo "            <th scope=\"col\">Address</th>" >> $html
    echo "            <th scope=\"col\">Enquiry Phone Number</th>" >> $html
    echo "            <th scope=\"col\">Number of Courts</th>" >> $html
    echo "            <th scope=\"col\">Opening Hours</th>" >> $html
    echo "          </tr>" >> $html
    echo "        </thead>" >> $html
    echo "        <tbody>" >> $html
    #content for html table 
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
        # gen Html table
        echo "          <tr>" >> $html
        echo "            <td class="table-success">$Name_of_Venue</td>" >> $html
        echo "            <td >$Address</td>" >> $html
        echo "            <td >$Enquiry_Phone_Number</td>" >> $html
        echo "            <td >$Number_of_Courts</td>" >> $html
        echo "            <td >$Opening_Hours</td>" >> $html
        echo "          </tr>" >> $html
        done
        ((total++))
    done
    #html foot
    echo -e "done! $total is processed"
    echo "        </tbody>" >> $html
    echo "      </table>" >> $html
    echo "" >> $html
    echo "    <!-- Optional JavaScript; choose one of the two! -->" >> $html
    echo "" >> $html
    echo "    <!-- Option 1: Bootstrap Bundle with Popper -->" >> $html
    echo "    <script src=\"https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/js/bootstrap.bundle.min.js\" integrity=\"sha384-ygbV9kiqUc6oa4msXn9868pTtWMgiQaeYH7/t7LECLbyPA2x65Kgf80OJFdroafW\" crossorigin=\"anonymous\"></script>" >> $html
    echo "" >> $html
    echo "    <!-- Option 2: Separate Popper and Bootstrap JS -->" >> $html
    echo "    <!--" >> $html
    echo "    <script src=\"https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.4/dist/umd/popper.min.js\" integrity=\"sha384-q2kxQ16AaE6UbzuKqyBE9/u/KzioAlnx2maXQHiDX9d4/zp8Ok3f+M7DPm+Ib6IU\" crossorigin=\"anonymous\"></script>" >> $html
    echo "    <script src=\"https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/js/bootstrap.min.js\" integrity=\"sha384-pQQkAEnwaBkjpqZ8RU1fF1AKtTcHJwFl3pblpTlHXybJjHpMYo79HY3hIi4NKxyj\" crossorigin=\"anonymous\"></script>" >> $html
    echo "    -->" >> $html
    echo "  </body>" >> $html
    echo "</html>" >> $html

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
    echo -e "$urlname.data not found\nplz use \"bash ./lscd_ver_html.sh update\""
    exit 1
fi