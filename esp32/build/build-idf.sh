#!/bin/bash
#esp_idf_branch=${1:-v2.0}
#esp_idf_branch=${1:-v2.1}
#espruino_branch=${2:-master}
#esp_idf_branch=${1:-v3.0}
#espruino_branch=${2:-ESP32-v3.0}
esp_idf_branch=${1:-v3.1}
#espruino_branch=${2:-master}
espruino_branch=${2:-ESP32-V3.1}
checkout_mode=${3:-none}
# Fresh cleans down to get new release
#checkout_mode=$(3:-fresh}
echo using esp-idf branch $esp_idf_branch, espruino branch $espruino_branch, checkout mode $checkout_mode

if [ ! -d "Espruino" ]; then
git clone https://github.com/espruino/Espruino.git
fi

if ! type xtensa-esp32-elf-gcc > /dev/null; then
    echo Looking for xtensa-esp32-elf-gcc
       if [ -d "xtensa-esp32-elf" ]; then
           export PATH=$PATH:`pwd`/xtensa-esp32-elf/bin/
       fi
fi
cd Espruino
source ./scripts/provision.sh ESP32
cd ..
# initialise the submodule folder
# This will need to be tied to a release
#git submodule update --init 

#cd esp-idf
#git fetch
#git checkout $esp_idf_branch
if [ "$checkout_mode" = "fresh" ]
then
        echo "refreshing to new sdk"
	rm -r esp-idf
	git clone -b $esp_idf_branch --recursive https://github.com/espressif/esp-idf.git esp-idf
	git submodule update --init --recursive
fi

echo `pwd`

# adjust paths to this folder versions
export ESP_IDF_PATH=`pwd`/esp-idf
export IDF_PATH=`pwd`/esp-idf
export ESP_APP_TEMPLATE_PATH=`pwd`
cd app
make clean
#make
make -j 5
# This is not the firmware - get rid of it!
rm build/espruino-esp32.elf
echo `pwd`
cd ..
make app.tgz
cd ../Espruino

# copy newly build libs and expand
tar xfz ../../deploy/esp-idf.tgz
tar xfz ../../deploy/app.tgz

git fetch
git checkout $espruino_branch
git pull
# reset the IDF_PATH
source ./scripts/provision.sh ESP32
make clean
BOARD=ESP32 make
ln -s app/build/bootloader/bootloader.bin
ln -s app/build/partitions_espruino.bin
cat targets/esp32/README_flash.txt
