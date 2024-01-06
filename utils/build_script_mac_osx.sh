set -x # echo on
set +e # switch off exit on error
curr_path=${BASH_SOURCE%/*}

# check that all the required environment vars are set
: "${CHN_QT_PATH:?variable not set, see also macosx_build_config.command}"
: "${CHN_BOOST_ROOT:?variable not set, see also macosx_build_config.command}"
: "${CHN_BOOST_LIBS_PATH:?variable not set, see also macosx_build_config.command}"
: "${CHN_BUILD_DIR:?variable not set, see also macosx_build_config.command}"
: "${CMAKE_OSX_SYSROOT:?CMAKE_OSX_SYSROOT should be set to macOS SDK path, e.g.: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk}"
: "${OPENSSL_ROOT_DIR:?variable not set, see also macosx_build_config.command}"

ARCHIVE_NAME_PREFIX=beezy-macos-x64-

if [ -n "$build_prefix" ]; then
  ARCHIVE_NAME_PREFIX=${ARCHIVE_NAME_PREFIX}${build_prefix}-
  build_prefix_label="$build_prefix "
fi

if [ "$testnet" == true ]; then
  testnet_def="-D TESTNET=TRUE"
  testnet_label="testnet "
  ARCHIVE_NAME_PREFIX=${ARCHIVE_NAME_PREFIX}testnet-
fi

######### DEBUG ##########
#cd "$CHN_BUILD_DIR/release/src"
#rm *.dmg
#if false; then
##### end of DEBUG ######

rm -rf $CHN_BUILD_DIR; mkdir -p "$CHN_BUILD_DIR/release"; cd "$CHN_BUILD_DIR/release"

cmake $testnet_def -D OPENSSL_ROOT_DIR=$OPENSSL_ROOT_DIR -D CMAKE_OSX_SYSROOT=$CMAKE_OSX_SYSROOT -D BUILD_GUI=TRUE -D CMAKE_PREFIX_PATH="$CHN_QT_PATH/clang_64" -D CMAKE_BUILD_TYPE=Release -D BOOST_ROOT="$CHN_BOOST_ROOT" -D BOOST_LIBRARYDIR="$CHN_BOOST_LIBS_PATH" ../..
if [ $? -ne 0 ]; then
    echo "Failed to cmake"
    exit 1
fi



make -j beezy
if [ $? -ne 0 ]; then
    echo "Failed to make beezy"
    exit 1
fi

make -j connectivity_tool daemon simplewallet
if [ $? -ne 0 ]; then
    echo "Failed to make binaries!"
    exit 1
fi


cd src/
if [ $? -ne 0 ]; then
    echo "Failed to cd src"
    exit 1
fi

# copy all necessary libs into the bundle in order to workaround El Capitan's SIP restrictions
mkdir -p beezy.app/Contents/Frameworks/boost_libs
cp -R "$CHN_BOOST_LIBS_PATH/" beezy.app/Contents/Frameworks/boost_libs/
if [ $? -ne 0 ]; then
    echo "Failed to cp workaround to MacOS"
    exit 1
fi

# rename process name to big letter 
mv beezy.app/Contents/MacOS/beezy beezy.app/Contents/MacOS/beezy
if [ $? -ne 0 ]; then
    echo "Failed to rename process"
    exit 1
fi

cp beezyd simplewallet beezy.app/Contents/MacOS/
if [ $? -ne 0 ]; then
    echo "Failed to copy binaries to beezy.app folder"
    exit 1
fi

# fix boost libs paths in main executable and libs to workaround El Capitan's SIP restrictions
source ../../../utils/macosx_fix_boost_libs_path.sh
fix_boost_libs_in_binary @executable_path/../Frameworks/boost_libs beezy.app/Contents/MacOS/beezy
fix_boost_libs_in_binary @executable_path/../Frameworks/boost_libs beezy.app/Contents/MacOS/simplewallet
fix_boost_libs_in_binary @executable_path/../Frameworks/boost_libs beezy.app/Contents/MacOS/beezyd
fix_boost_libs_in_libs @executable_path/../Frameworks/boost_libs beezy.app/Contents/Frameworks/boost_libs



"$CHN_QT_PATH/clang_64/bin/macdeployqt" beezy.app
if [ $? -ne 0 ]; then
    echo "Failed to macdeployqt beezy.app"
    exit 1
fi



rsync -a ../../../src/gui/qt-daemon/layout/html beezy.app/Contents/MacOS --exclude less --exclude package.json --exclude gulpfile.js
if [ $? -ne 0 ]; then
    echo "Failed to cp html to MacOS"
    exit 1
fi

cp ../../../src/gui/qt-daemon/app.icns beezy.app/Contents/Resources
if [ $? -ne 0 ]; then
    echo "Failed to cp app.icns to resources"
    exit 1
fi

codesign -s "Developer ID Application: beezy Limited" --timestamp --options runtime -f --entitlements ../../../utils/macos_entitlements.plist --deep ./beezy.app
if [ $? -ne 0 ]; then
    echo "Failed to sign beezy.app"
    exit 1
fi


read version_str <<< $(DYLD_LIBRARY_PATH=$CHN_BOOST_LIBS_PATH ./connectivity_tool --version | awk '/^beezy/ { print $2 }')
version_str=${version_str}
echo $version_str


echo "############### Prepearing archive... ################"
mkdir package_folder
if [ $? -ne 0 ]; then
    echo "Failed to zip app"
    exit 1
fi

mv beezy.app package_folder 
if [ $? -ne 0 ]; then
    echo "Failed to top app package"
    exit 1
fi

#fi

package_filename=${ARCHIVE_NAME_PREFIX}${version_str}.dmg

source ../../../utils/macosx_dmg_builder.sh
build_fancy_dmg package_folder $package_filename
if [ $? -ne 0 ]; then
    echo "Failed to create fancy dmg"
    exit 1
fi

echo "Build success"

echo "############### Uploading... ################"

package_filepath=$package_filename

scp $package_filepath beezy_build_server:/var/www/html/builds/
if [ $? -ne 0 ]; then
    echo "Failed to upload to remote server"
    exit 1
fi


read checksum <<< $( shasum -a 256 $package_filepath | awk '/^/ { print $1 }' )

mail_msg="New ${build_prefix_label}${testnet_label}build for macOS-x64:<br>
https://build.beezy.io/builds/$package_filename<br>
sha256: $checksum"

echo "$mail_msg"

echo "$mail_msg" | mail -s "beezy macOS-x64 ${build_prefix_label}${testnet_label}build $version_str" ${emails}


######################
# notarization
######################

cd package_folder

echo "Notarizing..."

# creating archive for notarizing
echo "Creating archive for notarizing"
rm -f beezy.zip
/usr/bin/ditto -c -k --keepParent ./beezy.app ./beezy.zip

tmpfile="tmptmptmp"
xcrun altool --notarize-app --primary-bundle-id "org.beezy.desktop" -u "dev@beezy.io" -p "@keychain:Developer-altool" --file ./beezy.zip > $tmpfile 2>&1
NOTARIZE_RES=$?
NOTARIZE_OUTPUT=$( cat $tmpfile )
rm $tmpfile
echo "NOTARIZE_OUTPUT=$NOTARIZE_OUTPUT"
if [ $NOTARIZE_RES -ne 0 ]; then
    echo "Notarization failed"
    exit 1
fi

GUID=$(echo "$NOTARIZE_OUTPUT" | egrep -Ewo '[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}')
if [ ${#GUID} -ne 36 ]; then
    echo "Couldn't get correct GUID from the response, got only \"$GUID\""
    exit 1
fi


success=0

# check notarization status
for i in {1..10}; do
    xcrun altool --notarization-info $GUID -u "dev@beezy.io" -p "@keychain:Developer-altool" > $tmpfile 2>&1
    NOTARIZE_OUTPUT=$( cat $tmpfile )
    rm $tmpfile 
    NOTARIZATION_LOG_URL=$(echo "$NOTARIZE_OUTPUT" | sed -n "s/.*LogFileURL\: \([[:graph:]]*\).*/\1/p")
    if [ ${#NOTARIZATION_LOG_URL} -ge 30 ]; then
        success=1
        curl -L $NOTARIZATION_LOG_URL
        break
    fi
    sleep 60 
done

if [ $success -ne 1 ]; then
    echo "Build notarization failed"
    exit 1
fi

echo "Notarization done"
