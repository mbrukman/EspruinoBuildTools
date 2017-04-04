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
export IDF_PATH=$ESP_IDF_PATH
# initialise the submodule folder
# This will need to be tied to a release
git submodule update --init
cd esp-idf
git fetch
git checkout v2.0-rc2
git submodule update --init
cd ..
# adjust paths to this folder versions
export ESP_IDF_PATH=`pwd`/esp-idf
export ESP_APP_TEMPLATE_PATH=`pwd`
cd app
make clean
make -j 5
# This is not the firmware - get rid of it!
rm build/espruino-esp32.bin
make app.tgz
cd ../Espruino
# copy newly build libs and expand
tar xfz ../../deploy/esp-idf.tgz
tar xfz ../../deploy/app.tgz
git fetch
# reset the IDF_PATH
source ./scripts/provision.sh ESP32
make clean
BOARD=ESP32 make
cat targets/esp32/README_flash.txt
