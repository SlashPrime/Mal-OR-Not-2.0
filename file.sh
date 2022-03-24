#!/bin/bash
vt_file() {
    # Submit a file
    APIKEY="d2d01393e9c34f7d20d08625f1aa6409e8323a9765568dc88a38a2a330213f2f"
    FILE="$1"
    local FSIZE=$(stat $FILE | grep "Size:" | awk '{print $2}')
    if [[ $FSIZE -gt 33554431 ]]; then
      vt_bigfile "$APIKEY" "$FILE"
    else
      curl -s --request POST --url "https://www.virustotal.com/api/v3/files" --header "x-apikey: $APIKEY" --form "file=@$FILE" >> $name.file.output1
    fi
}

vt_bigfile() {
    # files > 32M need a special upload URL
    APIKEY="d2d01393e9c34f7d20d08625f1aa6409e8323a9765568dc88a38a2a330213f2f"
    FILE="$1"
    URL=$(curl -s --request GET --url "https://www.virustotal.com/api/v3/files/upload_url" --header "x-apikey: $APIKEY" | jq -r .data)
    curl -s --request POST --url "$URL" --header "x-apikey: $APIKEY" --form "file=@$FILE" >> $name.file.output1
}
FILE="$1"
name=$(echo $FILE |awk -F "/" '{print $NF}' | awk -F "." '{print $1}')
file_name=$(echo $FILE |awk -F "/" '{print $NF}')
echo -e "File: $file_name">output/file/$name.file.report
vt_file "$FILE"
id=$(cat $name.file.output1 | jq | grep id | awk -F "\"" '{print $4}')
rm $name.file.output1
sleep 10
function fileInfo(){
curl -s --request GET --url "https://www.virustotal.com/api/v3/analyses/$1" --header "x-apikey: d2d01393e9c34f7d20d08625f1aa6409e8323a9765568dc88a38a2a330213f2f" > $2.file.output2
}
fileInfo "$id" "$name"
cat $name.file.output2 | grep status | grep queued > /dev/null 
if [[ $? -eq 0 ]] ; then sleep 5; echo "[i] Results are being evaluated. Have patience."; fileInfo "$id" "$name" ; fi 
echo -e "According to VirusTotal API:\n" >> output/file/$name.file.report
cat $name.file.output2 | grep -E "malicious|suspicious|undetected|harmless"  | grep -vE "category|result" | tr -d "\"," | sed 's/\<\([[:lower:]]\)\([[:alnum:]]*\)/\u\1\2/g' | sed 's/^ *//g' | awk 'BEGIN{ RS = "" ; FS = "\n" }{print $3,"\n",$2,"\n",$1,"\n",$4}' | sed 's/^ *//g' >>output/file/$name.file.report
mal_list=$(cat $name.file.output2 | grep -E "malicious" -A 5 | grep engine_name | awk -F "\"" '{print $4}' )

if [ ! -z "$mal_list" ];
then result=$(for i in $(echo $mal_list); do result=$(cat $name.file.output2 | grep -w "$i\"" -A 3 | grep result | tr -d "\"," | awk -F ":" '{print $2}') ; echo "$i - $result" ; done
)
echo -e "\nSources that say it is malicious:\n$result" >>output/file/$name.file.report
cat output/file/$name.file.report>> output/file/file.master.report
else 
echo "The file appears to be safe to use! :D" >> output/url/$name.url.report
fi
rm $name.file.output2
