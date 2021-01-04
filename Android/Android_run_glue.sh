echo "[*] starting glue."

echo "[*] Usage: this script runs OWASP Glue on on the provided provided mobsf json file."
echo "-----------------------------------------------"
echo "[*] The script one requires variable. set this variable via azure and not as a shell variable"
# echo "[*] 1 -> \$package_file_path - File path"
echo "[*] 2 -> complete path for json report"
# echo "[*] 3 -> \$pdf_report_file_path - complete path for pdf report"
echo
echo "[*] Make sure docker is installed and accessible"
echo "[*] Make sure the artifacts are generated and pushed before running this script"
echo "-----------------------------------------------"
echo "Starting . . ."
echo
echo

echo "[*] Starting glue container.."
dir_name=`dirname $1`
file_name=`basename $1`

echo "[*] report dir name -> $dir_name"
echo "[*] report file name -> $file_name"
echo
echo "[*] Analyzing report . . "
echo

if `docker run -v $dir_name:/app owasp/glue:raw-latest ruby bin/glue -t Dynamic -T /app/$file_name --mapping-file mobsf --finding-file-path /app/android.json -z 2`; then
    echo "Glue scan is successful."
else
    touch $dir_name/failed
    echo "Glue analysis failed, maybe the code has bugs. it could be possible analysis failed."
fi

echo "finishing task..."
echo "task finished"