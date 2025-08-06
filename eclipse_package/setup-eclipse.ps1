# Eclipse Download Script
# This script downloads and sets up Eclipse with Activiti support

# Download Eclipse IDE for Java Developers
Invoke-WebRequest -Uri 'https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2023-03/R/eclipse-java-2023-03-R-win32-x86_64.zip&mirror_id=1' -OutFile 'eclipse.zip'
Expand-Archive -Path 'eclipse.zip' -DestinationPath 'C:\' -Force
Write-Host 'Eclipse installed to C:\eclipse'

# Install BPMN2 Modeler Plugin
C:\eclipse\eclipse.exe -application org.eclipse.equinox.p2.director -noSplash -repository https://download.eclipse.org/bpmn2-modeler/updates/ -installIU org.eclipse.bpmn2.modeler.feature.feature.group

