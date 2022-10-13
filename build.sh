#!/bin/bash
#
#
#
#
#
#
#
#
#
#
#
#
#
#
######################################################
echo " "
KERNEL_DIR=$(pwd)
CURRENT_BUILD_USER=$(whoami)

# 
if [[ ${CURRENT_BUILD_USER} == "neel" ]]; then
    export KBUILD_BUILD_USER=Neel0210
    export KBUILD_BUILD_HOST=Hell
else
    export KBUILD_BUILD_USER=BuildBot
    export KBUILD_BUILD_HOST=KangHub
fi

# Colours
GRN='\033[01;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RED='\033[01;31m'
RST='\033[0m'

# Arch and Android Version
export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=s
export PLATFORM_VERSION="12"

# Kernel related Information
ZIMG=out/arch/arm64/boot/Image
KERNEL_CONFIG=a50_00_defconfig
TC=$HOME/KKRT_TC/proton

exit_script() {
    kill -INT $$
}

# Compiler
if [[ -d "${TC}" ]]; then
    echo -e "${CYAN}Exporting path"
    export CROSS_COMPILE=$HOME/KKRT_TC/gcc49/bin/aarch64-linux-android-
    export CLANG_TRIPLE=$HOME/KKRT_TC/proton/bin/aarch64-linux-gnu-
    export CC=$HOME/KKRT_TC/proton/bin/clang
else
    echo -e "${YELLOW}Clonning toolchain"
    rm -rf $HOME/KKRT_TC/*
    git clone --depth=1 https://github.com/KakarotKernel/Toolchains-for-Eureka.git -b GCC-4.9 $HOME/KKRT_TC/gcc49
    git clone --depth=1 https://github.com/KakarotKernel/Toolchains-for-Eureka.git -b proton_clang_13 $HOME/KKRT_TC/proton
    echo -e "${CYAN}Exporting path"
    export CROSS_COMPILE=$HOME/KKRT_TC/gcc49/bin/aarch64-linux-android-
    export CLANG_TRIPLE=$HOME/KKRT_TC/proton/bin/aarch64-linux-gnu-
    export CC=$HOME/KKRT_TC/proton/bin/clang
fi

START(){
    # Calculate compilation time
    START=$(date +"%s")
}
#
END(){
    if [ -f out/arch/arm64/boot/Image ];then
        clear && FLEX
        echo " " && echo " "
        END=$(date +"%s")
        DIFF=$((END - START))
        echo " " && echo -e "${GRN}Kernel has been compiled successfully and it took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)${RST}"
    else
        exit_script
    fi
}

FLEX(){
echo -e "${YELLOW}                                                     "
echo " _   __ _   ________ _____                 _       _     "
echo "| | / /| | / /| ___ \_   _|  ___  ___ _ __(_)_ __ | |_ "
echo "| |/ / | |/ / | |_/ / | |   / __|/ __| '__| | '_ \| __|"
echo "|    \ |    \ |    /  | |   \__ \ (__| |  | | |_) | |_  "
echo "| |\  \| |\  \| |\ \  | |   |___/\___|_|  |_| .__/ \__|"
echo "\_| \_/\_| \_/\_| \_| \_/                   |_|         "
echo " "
echo -e "${GRN}                coded by Neel0210  ${RST}"
}

# Device database
A50(){
    DEVICE_KERNEL_BOARD='SRPRL05B009KU'
    DEVICE_KERNEL_BASE=0x10000000
    DEVICE_KERNEL_PAGESIZE=2048
    DEVICE_RAMDISK_OFFSET=0xf0000000
    DEVICE_SECOND_OFFSET=0xf0000000
    PLATFORM_VERSION="11.0.0"
    PLATFORM_PATCH_LEVEL="2022-07"
    DEVICE_KERNEL_CMDLINE="" 
    DEVICE_KERNEL_HEADER=1
    DEVICE_DTB_HASHTYPE='sha1'  
    DEVICE_KERNEL_OFFSET=0x00008000 
    DEVICE_TAGS_OFFSET=0x00000100
    DEVICE_HEADER_SIZE=1648
}

N10L(){
    DEVICE_KERNEL_BOARD='SRPSI06A008'
    DEVICE_KERNEL_BASE=0x10000000
    DEVICE_KERNEL_PAGESIZE=2048
    DEVICE_RAMDISK_OFFSET=0x01000000
    DEVICE_SECOND_OFFSET=0xf0000000
    PLATFORM_VERSION="12.0.0"
    PLATFORM_PATCH_LEVEL="2022-06"
    DEVICE_KERNEL_CMDLINE="" 
    DEVICE_KERNEL_HEADER=2
    DEVICE_DTB_HASHTYPE='sha1'  
    DEVICE_KERNEL_OFFSET=0x00008000 
    DEVICE_TAGS_OFFSET=0x00000100
    DEVICE_HEADER_SIZE=1660
    DEVICE_DTB_OFFSET=0x00000000
}

clean(){
    echo " "    
    echo -e "${RED}                     Cleaning${RST}" && echo " "
    make clean
    make mrproper
}

build(){
    echo " "
    echo -e "${BOLD}                          Compiling${RST}" && echo " "
    #
    make $KERNEL_CONFIG O=out CC=clang
    make -j$(nproc --all) O=out CC=clang
}

check_build(){
        echo " " && echo " "

        echo -e "${YELLOW}                     x Building Boot.img x"
        A50
        #
        $(pwd)/tools/make/bin/mkbootimg \
                  --kernel $ZIMG \
                  --cmdline " " --board "$DEVICE_KERNEL_BOARD" \
                  --base $DEVICE_KERNEL_BASE --pagesize $DEVICE_KERNEL_PAGESIZE \
                  --kernel_offset $DEVICE_KERNEL_OFFSET --ramdisk_offset $DEVICE_RAMDISK_OFFSET \
                  --second_offset $DEVICE_SECOND_OFFSET --tags_offset $DEVICE_TAGS_OFFSET \
                  --os_version "$PLATFORM_VERSION" --os_patch_level "$PLATFORM_PATCH_LEVEL" \
                  --header_version $DEVICE_KERNEL_HEADER --hashtype $DEVICE_DTB_HASHTYPE \
                  -o $(pwd)/boot.img
                  sleep 2
#
if [ -f ${KERNEL_DIR}/boot.img ];then
    echo -e "${GRN}Image has been built at $(pwd)/boot.img${RST}"
else
    echo -e "${RED}Check for error"
fi
}

clear
FLEX
clean
clear && FLEX && START
build
END
check_build

################ END OF LIFE ###############
