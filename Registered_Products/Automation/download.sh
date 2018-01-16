#!/usr/bin/env bash
set -xe

# Download new FDA data files.
echo ***Downloading FDA data files...
wget -r http://www.fda.gov/downloads/Drugs/InformationOnDrugs/UCM163762.zip -O fda_files.zip