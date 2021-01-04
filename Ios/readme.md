# MobSF iOS-Native.

This script is specifically desinged for Mac os based runners.

### Requirements-

* Mac OS runner
* python 3.6

> The script will only work with python 3.6 .
 The **"Use Python version"** task can be used to install correct version of python

example yaml to install python 3.6 :

    steps:
    - task: UsePythonVersion@0
      displayName: 'Use Python 3.6.*'
      inputs:
        versionSpec: '3.6.*'

### Usage
Clone the script and run with supplied variables.


    git clone https://github.com/neerajnigam6/Mobsf-AzureDevops.git
    cd Mobsf-AzureDevops
    chmod +x Ios/IOS_run_mobsf.sh
    ./Ios/IOS_run_mobsf.sh $ipa_path $json_path $pdf_path


The script expects following positional arguments.
* $1 => file_name => the complete path of application package file. ex: "/var/release/application.ipa"
* $2 => json_path => complete path for json report, including filename. Mobsf by default generates pdf and json reports, this path specifies where to store json report. example: "/var/release/my_json_report.json"
* $3 => pdf_path => complete path for pdf report, including filename. Currently this script assumes both pdf and json reports need to be created in a same parent directory, however still this parameter expects complete path for pdf report. ex: "/var/release/pdf_report.pdf"

> The script generates the security reports. Publication and processing of the report is left to the project team. 

Below mentioned task example can be used to publish the report as an artifact for further processing.

    steps:
    - task: PublishPipelineArtifact@1
      displayName: 'Publish MobSF report'
      inputs:
          targetPath: '$(build.artifactStagingDirectory)' # or any directory which hosts the generated reports
          artifact: 'Security_Reports'


