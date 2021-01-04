# CI-security

### Introduction

This project will provide a solution to mobile applications scanning. A CI pipeline can leverage the powerful mobile application scanning tool **Mobsf** in their build pipeline and can proactively identify and fix issues before submitting it to the security team.

These set of scripts can be used in the Azure devops CI for mobile applications and can be integrated easily.

Please refer to respective folders for iOS or android scanners.

The script is scrictly developed for Azure devops and currently only support Azure devops. however it can be ported to other platforms with minimal effort.

### Installation

Clone the scripts manually or add below mentioned yaml task

    - script: |
      cd $(System.DefaultWorkingDirectory) & git clone https://github.com/neerajnigam6/Mobsf-AzureDevops.git
      echo $(System.DefaultWorkingDirectory)
    displayName: 'Clone Security scripts'

Please refer to individual documentation for iOS and Android for usage information.