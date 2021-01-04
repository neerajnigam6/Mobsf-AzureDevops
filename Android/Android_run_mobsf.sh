#! /bin/bash

echo "[*] Usage: this script runs mobsf scanner based on the provided APK file path."
echo "-----------------------------------------------"
echo "[*] The script requires 3 variables. set these variable via azure and not as a shell variable"
echo "[*] 1 -> File path"
echo "[*] 2 -> complete path for json report"
echo "[*] 3 -> complete path for pdf report"
echo
echo "[*] Make sure docker is installed and accessible"
echo "-----------------------------------------------"
echo "Starting . . ."
echo
echo


if [ "$#" -lt 3 ] ;
then 
    echo "Parameters missing, please provide all parameters"
    echo "param1 => package_file_full_path, 2=> json_file_full_path, 3=> pdf_file_full_path"
    echo "Exiting .. "
    exit
fi


echo "[*] started."
echo "[*] pulling latest mobsf image from docker hub" 
echo "[*] use strong API key"
docker run --rm -d --env MOBSF_API_KEY=12345 -p 8000:8000 opensecurity/mobile-security-framework-mobsf:v3.1.1
echo "[*] mobsf started successfully."
echo "[*] Sleeping for 30 sec, let mobsf boot from coldstart."
sleep 30
echo "[*] woke up ready to upload package for scanning."
echo "[*] trying upload of the file- $1"


upload=$(curl -F file=@$1 http://localhost:8000/api/v1/upload -H "Authorization:12345" )

if [ -z $upload ];
then 
  echo "!!! error uploading package file, exiting."
  exit
else 
  echo "[*] upload complete"
fi


echo
echo "[*] result of upload curl... -> $upload"
echo
echo "[*] creating directory for json and pdf file, assuming both share same parent folder, make sure you specify this path"
echo "[*] during artifact publish"
echo
mkdir -p `dirname $2`
echo "[*] directory created"
ls `dirname $2`

echo "[*] ectracting file hash and name."
hash=`echo $upload | jq .hash | sed 's/.//;s/.$//'`
name=`echo $upload | jq .file_name | sed 's/.//;s/.$//'`
echo "[*] report pull required for file $name with hash $hash"
echo "[*] trying to pull json report"
curl -X POST --url http://localhost:8000/api/v1/scan --data "scan_type=apk&file_name=$name&hash=$hash" -H "Authorization:12345" > $2
echo "[*] json report generation success"
echo "[*] pulling pdf report"
curl -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$hash" -H "Authorization:12345" --output $3
echo "[*] pdf report generation success"
echo "[*] artifacts are generated, upload can be initiated."
echo "[*] Done"
