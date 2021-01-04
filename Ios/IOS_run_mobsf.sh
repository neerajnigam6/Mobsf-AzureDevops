echo "starting the script"
echo "cloning mobsf"

echo "[*] Usage: this script runs mobsf scanner based on the provided APK file path."
echo "-----------------------------------------------"
echo "[*] The script requires 3 variables. set these variable via azure and not as a shell variable"
echo "[*] 1 -> File path"
echo "[*] 2 -> complete path for json report"
echo "[*] 3 -> complete path for pdf report"
echo "[*] 4 -> default working directory"
echo
echo "[*] Make sure docker is installed and accessible"
echo "-----------------------------------------------"
echo "Starting . . ."
echo
echo


if [ "$#" -lt 4 ] ;
then 
    echo "Parameters missing, please provide all parameters"
    echo "1 = package_file_path"
    echo "2 = json_report_file_path"
    echo "3 = pdf_report_file_path"
    echo "4 = DefaultWorkingDirectory"
    echo "Exiting .. "
    exit
fi

file_name=$1
json_file_name=$2
pdf_file_name=$3
default_working_directory=$4
echo "the below line make sure we do not have problems uploading file due to special characters in IPA name"
default_package_app_name=$default_working_directory/application.ipa

echo "json_file_name => $json_file_name "
echo "pdf_file_name => $pdf_file_name "
echo "package file path -> $file_name message"
echo "remove default working directory as it is no longer needed"
echo "default working directory -> $default_working_directory"

echo "---------------------------------"
echo "Copying ipa package to remove potential special characters"
echo "working in :" $(pwd)
cp -v "$file_name" $default_package_app_name

echo "Downloading cocoa pdf lib"
wget --quiet -O /tmp/wkhtmltox-0.12.6-2.macos-cocoa.pkg "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-2/wkhtmltox-0.12.6-2.macos-cocoa.pkg" && 
    sudo installer -pkg /tmp/wkhtmltox-0.12.6-2.macos-cocoa.pkg  -target /Applications && 
    ln -s /usr/local/bin/wkhtmltopdf /usr/bin && 
    rm -f /tmp/wkhtmltox-0.12.6-2.macos-cocoa.pkg 

echo "Cocoa pfd lib version."
wkhtmltopdf  -V

echo "Setup done starting MobSF installation and setup"
echo "---------------------------------"
echo "cloninb MobSF"
git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git
echo "cloning successful"
echo "starting mobsf setup.sh"
echo "cd Mobile-Security-Framework-MobSF"
cd Mobile-Security-Framework-MobSF
echo "making mobsf setup.sh and run.sh executable"
chmod +x setup.sh run.sh
echo "listing out contents of MobSF directory [ls -la]"
ls -la
echo "Exporting MOBSF_API_KEY=*********"
export MOBSF_API_KEY=12345
echo "Starting setup [./setup.sh]"
./setup.sh
echo "Mobsf setup complete." 
echo "---------------------------------"
echo
echo "starting mobsf integrated server."
./run.sh 127.0.0.1:8000 &
echo "Mobsf started in the background, sleeping for 30 seconds so that mobsf can initiate coldboot"
sleep 30

echo "trying upload of package file."
echo "filename => $file_name"

upload=$(curl -F "file=@$default_package_app_name" http://localhost:8000/api/v1/upload -H "Authorization:12345" )
echo $upload
hash=`echo $upload | jq .hash | sed 's/.//;s/.$//'`
name=`echo $upload | jq .file_name | sed 's/.//;s/.$//'`

echo
echo "result of upload curl... -> $upload"
echo
echo "creating directory for json and pdf file, assuming both share same parent folder, make sure you specify this path"
echo "during artifact publish"
echo
mkdir -p `dirname $json_file_name`
echo "directory created"
ls `dirname $json_file_name`


curl -X POST --url http://localhost:8000/api/v1/scan --data "scan_type=ipa&file_name=$name&hash=$hash" -H "Authorization:12345" > $json_file_name

curl -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$hash" -H "Authorization:12345" --output $pdf_file_name

echo "Reports generated. Done"