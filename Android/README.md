# Mobsf Android-docker

### Requirements

The script expects linux based runners we currently do not support windows based runners.

Docker agent.

    - task: DockerInstaller@0
      displayName: '[Sec] Install Docker 17.09.0-ce'

### Usage:
There are two separate scripts the __Android_run_mobsf.sh__ and __Android_run_glue.sh__

#### Android_run_mobsf.sh
This script by default pulls a docker image of latest Mobsf scanner and scans the Apk based on supplied variables. The script will generate two separate reports, a json based report and a pdf report. The json report then can be fed to OWASP glue for report processing.

Three positional variables need to be supplied.
1. $1 => full path of apk file. ex: /var/release/my_application.apk
2. $2 => full path of json report (Script will generate file at this path ex.: /var/release/report.json)

3. $3 => full path of pdf report (Script will generate pdf file at this path ex.: /var/release/report.pdf)

> The json report and pdf report both must have same parent directory, filenames can be different.

A sample code would be

      - task: Bash@3
        displayName: 'MobSF scan'
        inputs:
            targetType: 'inline'
            script: |
                bash /var/Mobsf-AzureDevops/Android/Android_run_mobsf.sh $(package_file_path) $(json_report_file_name) $(pdf_report_file_name)


#### OWASP Glue task - WIP
The OWASP glue can be used as a logic engine for **Mobsf** reports. The Glue task can process the Mobsf generated report and can fail the build if it has security issues. This task is currently in beta mode and generate a report of issues instead of failing the build.

> Requirements - same as of MobSF script

The Glue task expects one positional parameter which is path of json report. The full path of json report should be supplied as the parameter and it can be recycled from Mobsf task mentioned above.

The Glue task generates a file named **"android.json"** in the same directory as of supplied json report. This file contains more sanitized version of vulnerabilities. The development team should prioritize fixing vulnerabilities mentioned in Glue generated **android.json** as these are generally high/critical severity issues.

A sample yaml code would be:

    - task: Bash@3
      inputs:
        targetType: 'inline'
        script: |
          bash /var/Mobsf-AzureDevops/Android/Android_run_glue.sh $(json_report_file_name)
      displayName: 'Glue Scan'

The dev team should push the artifacts after both the steps to get the reports for further analysis.

