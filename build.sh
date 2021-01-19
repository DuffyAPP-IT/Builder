#!/bin/bash

echo "  _______   __  __    ________  __       ______   ______   ______       ";
echo "/_______/\ /_/\/_/\  /_______/\/_/\     /_____/\ /_____/\ /_____/\      ";
echo "\::: _  \ \\:\ \:\ \ \__.::._\/\:\ \    \:::_ \ \\::::_\/_\:::_ \ \     ";
echo " \::(_)  \/_\:\ \:\ \   \::\ \  \:\ \    \:\ \ \ \\:\/___/\\:(_) ) )_   ";
echo "  \::  _  \ \\:\ \:\ \  _\::\ \__\:\ \____\:\ \ \ \\::___\/_\: __ \`\ \  ";
echo "   \::(_)  \ \\:\_\:\ \/__\::\__/\\:\/___/\\:\/.:| |\:\____/\\ \ \`\ \ \ ";
echo "    \_______\/ \_____\/\________\/ \_____\/ \____/_/ \_____\/ \_\/ \_\/ ";
echo "                                                                        ";
echo "v1 - DuffyAPP-IT - @J_DUFFY01";

if [ $# -eq 0 ]
then
    echo -e "Usage: ./build.sh PROJECT_DIR WORKSPACE_FILE BUILD_SCHEME BUILD_CONFIG PACKAGES_PROJECT DEVELOPER_INSTALLER_ID"
    exit 1
fi


PROJECT_DIR="$1"
WORKSPACE="$2"
BUILD_SCHEME="$3"
BUILD_CONFIG="$4"
PACKAGES_PROJECT="$5"
DEVAPPINSTALLSIGNING=$(echo "$6" | sed 's/\\//g')
#echo $DEVAPPINSTALLSIGNING
#echo productsign --sign \"$DEVAPPINSTALLSIGNING\" ~/dapit_build/exported/*.pkg  ~/dapit_build/exported/signed.pkg
#echo "productsign --sign \"$DEVAPPINSTALLSIGNING\" ~/dapit_build/exported/signed.pkg"

if [ -z "$1" ]
then
    echo "[!] No Xcode Project Directory Supplied";
    exit 1
fi
if [ -z "$2" ]
then
    echo "[!] No Workspace Filename Supplied";
    exit 1
fi
if [ -z "$3" ]
then
    echo "[!] No Build Scheme Supplied";
    exit 1
fi

if [ -z "$4" ]
then
    echo "[!] No Build Config Supplied";
    exit 1
fi

if [ -z "$5" ]
then
    echo "[!] No Package Project Supplied";
    exit 1
fi

sudo rm -rf ~/dapit_build 2>/dev/null
mkdir ~/dapit_build ~/dapit_build/exported

cd "$1" 2>/dev/null

if cd "$1" ; then
    echo "[+] Archiving Application";
    if xcodebuild -workspace "$2" -config $4 -scheme $3 -archivePath ~/dapit_build/archive/out.xcarchive archive >/dev/null; then
            echo "[+] Extracting Archived Application"
            if cp -r ~/dapit_build/archive/out.xcarchive/Products/Applications ~/dapit_build/archive/exported; then
                    echo "[+] Packaging"
                    if packagesbuild $5 --build-folder ~/dapit_build/exported/; then
                        productsign --sign \"$DEVAPPINSTALLSIGNING\" ~/dapit_build/exported/*.pkg  ~/dapit_build/exported/signed.pkg
                        if productsign --sign $DEVAPPINSTALLSIGNING ~/dapit_build/exported/*.pkg  ~/dapit_build/exported/signed.pkg ; then
                            echo "[+] Launching Package"
                            open ~/dapit_build/exported/signed.pkg
                        else
                            echo "[!] fail packaging"
                        fi
                    else
                        echo "[!] failed signing"
                    fi
                            
                else
                    echo "[!] Failed To Extract Exported Application"
                fi
            else
                echo "[!] Archiving Project Failed - Check Your Build Configuration"
            fi
    else
    echo "[!] Project Directory Access Failed"
fi

exit 1

#echo "[+] Archiving Application";
#xcodebuild -workspace "$2" -config $4 -scheme $3 -archivePath ~/dapit_build/archive/out.xcarchive archive
#
#echo "[+] Extracting Archived Application"
#cp -r ~/dapit_build/archive/out.xcarchive/Products/Applications ~/dapit_build/archive/exported
##
#echo "[+] Packaging"
#packagesbuild $5 --build-folder ~/dapit_build/exported/
##
#echo "[+] Launching"
#open ~/dapit_build/exported/*.pkg
