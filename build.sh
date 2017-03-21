#!/bin/bash

# general define 
DEALER_NAME_MAP=(
	"168:公开版"
	"00708:东兴"
    "00024:方正"
    "00666:华宝"
    "00015:海通"
)
DEALER_NAME=""


#### define color
ORANGEC='\033[0;33m'
REDC='\033[1;31m'
NC='\033[0m'

#### 確認安装git
if !(hash git 2>/dev/null);
then
echo "\n${REDC}需要安装git command！${NC}\n" && exit 0
fi

#### 確認安装xctool
if !(hash xctool 2>/dev/null);
then
echo "\n${REDC}需要安装xctool command！${NC}\n" && exit 0
fi


#### git clone
if [[ -z $TMPDIR ]]
then
echo "\n${REDC}env variable TMPDIR empty！${NC}\n" && exit 0
fi

####
GIT_REPO_ADDR="https://git.mitake.com.cn/CrystalRD1/MApi.git"
SAMPLE_GIT_REPO_ADDR="https://git.mitake.com.cn/CrystalRD1/MApiSample.git"

cd $TMPDIR
echo "`pwd`"

rm -rf MApi
git clone $GIT_REPO_ADDR

if [ $? -ne 0 ]
then
echo "\n${REDC}git clone 错误！${NC}\n" && exit 0
fi

cd MApi
git tag -l

echo =====================
INPUT_FLOW=0
while [ true ]
do
# --------------- 0
if [ $INPUT_FLOW -eq 0 ]
then
read -p "请输入git tag(at ${GIT_REPO_ADDR}):" git_tag
test -z ${git_tag} && echo "\n${REDC}git tag不可为空！${NC}\n" && continue
echo "${ORANGEC}   ＃ CHECKOUT TAG ${git_tag}${NC}"
git checkout $git_tag
if [ $? -ne 0 ]
then
echo "\n${REDC}GIT CHECKOUT TAG ${git_tag} 错误！${NC}\n" && continue
fi
INPUT_FLOW=1
fi

# --------------- 1
if [ $INPUT_FLOW -eq 1 ]
then
read -p "请输入券商代码 (press enter set default):" bid
if [[ -z $bid ]]; then
	bid="168"
fi
INPUT_FLOW=2
fi

# --------------- 2
if [ $INPUT_FLOW -eq 2 ]
then
read -p "认证IP(0:全真/1:生产, press enter set default)?:" ip_mode

ARG_0="MAPI_AUTH_IP_TYPE_PRODUCTION=0"
MAPI_ENV_NAME="全真"
case $ip_mode in
[1]* ) 
ARG_0="MAPI_AUTH_IP_TYPE_PRODUCTION=1"
MAPI_ENV_NAME="生产" ;;
esac
INPUT_FLOW=3
fi

# --------------- 3
if [ $INPUT_FLOW -eq 3 ]
then
read -p "scheme(0:MApi/1:MApiUI, press enter set default)?:" ip_mode

M_SCHEME="MApi"
case $ip_mode in
[1]* ) M_SCHEME="MApiUI"
esac
INPUT_FLOW=4
fi

# --------------- 4
if [ $INPUT_FLOW -eq 4 ]
then
read -p "是否要SampleCode(y/n, press enter set default)?:" sample_needed
if [[ -z $sample_needed ]]; then
	sample_needed="y"
fi
case $sample_needed in
[nN]* ) break ;;
esac
INPUT_FLOW=5
fi

# --------------- 5
if [ $INPUT_FLOW -eq 5 ]
then
read -p "Bundle Id (press enter set default):" input_bundle_id
if [[ -z $input_bundle_id ]]; then
	input_bundle_id="com.mitake.public.CrystalTouch"
fi
INPUT_FLOW=6
fi

# --------------- 6
if [ $INPUT_FLOW -eq 6 ]
then
read -p "App Key (press enter set default):" input_app_key
if [[ -z $input_app_key ]]; then
	input_app_key="Vv7UoNqBKohrvYs0a+8Y+YoM1ZthBmVJFzW1fmeJBNk="
fi
INPUT_FLOW=7
fi

break
done

####
BUILD_PATH="`pwd`/build"

####
echo "${ORANGEC}   ＃ 清除旧的BUILD PATH${NC}"
echo           "      - ${BUILD_PATH}\n"
rm -rf $BUILD_PATH

####
echo "${ORANGEC}   ＃ 建立BUILD PATH${NC}"
echo           "      - ${BUILD_PATH}\n"
mkdir $BUILD_PATH

# define xcode env
SYMROOT="${BUILD_PATH}/Build/Products"
BUILD_DIR="${BUILD_PATH}/Build/Products"
BUILD_ROOT="${BUILD_PATH}/Build/Products"
CONFIGURATION="Release"
#PROJECT_NAME="MApi"

# define build param
UNIVERSAL_OUTPUTFOLDER="${BUILD_DIR}/${CONFIGURATION}-universal"

# 券商ID
CORP_ID_STRING='MAPI_CORP_ID=@"'${bid}'"'
ARG_1=`printf %q ${CORP_ID_STRING}`

# SDK版號
SDK_VER_STRING='MAPI_SDK_VER=@"'${git_tag}'"'
ARG_2=`printf %q ${SDK_VER_STRING}`

DEV_ARCH_STRING='MAPI_ARCH=@"i386_x86_64"'
DEV_ARG_3=`printf %q ${DEV_ARCH_STRING}`

DIST_ARCH_STRING='MAPI_ARCH=@"armv7_armv7s_arm64"'
DIST_ARG_3=`printf %q ${DIST_ARCH_STRING}`

# APP KEY
APP_KEY_STRING='MAPI_APP_KEY=@"'${input_app_key}'"'
ARG_4=`printf %q ${APP_KEY_STRING}`

# get folder name
for kv in "${DEALER_NAME_MAP[@]}" ; do
	DEALER_ID="${kv%%:*}"
	if [[ $DEALER_ID -eq $bid ]]; then
	    DEALER_NAME="${kv##*:}"
	    break
	fi
done

SUFFIX_FOLER_NAME="${git_tag}-${DEALER_NAME}${MAPI_ENV_NAME}"

#####
echo "\n客制编译参数："
echo "==============${SUFFIX_FOLER_NAME}==============="
echo "认证IP = ${ARG_0}"
echo "券商代码 = ${ARG_1}"

case $sample_needed in
[yY]* )
echo "BundleId = ${input_bundle_id}"
echo "AppKey = ${input_app_key}"
esac

echo "SDK VER = ${ARG_2}"
echo "scheme = ${M_SCHEME}"
echo "configuration = ${CONFIGURATION}"
echo "===============================================\n"

read -p "PRESS ANY KEY" NO_USE_VARIABLE

# build start
# iphoneos
xctool \
-scheme ${M_SCHEME} \
-configuration ${CONFIGURATION} \
-sdk iphoneos \
-derivedDataPath $BUILD_PATH \
GCC_PREPROCESSOR_DEFINITIONS="${DIST_ARG_3} ${ARG_2} ${ARG_1} ${ARG_0} ${ARG_4}" \
PRODUCT_BUNDLE_IDENTIFIER=${input_bundle_id} \
clean build

# simulator
xctool \
-scheme ${M_SCHEME} \
-configuration ${CONFIGURATION} \
-sdk iphonesimulator \
-derivedDataPath $BUILD_PATH \
VALID_ARCHS='i386 x86_64' \
GCC_PREPROCESSOR_DEFINITIONS="${DEV_ARG_3} ${ARG_2} ${ARG_1} ${ARG_0} ${ARG_4}" \
PRODUCT_BUNDLE_IDENTIFIER=${input_bundle_id} \
clean build

# universal
echo "${ORANGEC}   ＃ 建立UNIVERSAL FOLDER${NC}"
echo           "      - ${UNIVERSAL_OUTPUTFOLDER}\n"
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# lipo
echo "${ORANGEC}   ＃ 合并两个LIB${NC}"
echo           "      - 1. ${BUILD_DIR}/${CONFIGURATION}-iphoneos/lib${M_SCHEME}.a"
echo           "      - 2. ${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/lib${M_SCHEME}.a\n"
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/libMApi.a" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/lib${M_SCHEME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/lib${M_SCHEME}.a"

# copy headers
echo "${ORANGEC}   ＃ 复制头文件${NC}"
echo           "      - from ${BUILD_DIR}/${CONFIGURATION}-iphoneos/include/${M_SCHEME}"
echo           "      - to   ${UNIVERSAL_OUTPUTFOLDER}/include/MApi\n"

mkdir -p "${UNIVERSAL_OUTPUTFOLDER}/include/"
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include/${M_SCHEME}" "${UNIVERSAL_OUTPUTFOLDER}/include/MApi"

echo "\n\n"



# 是否要下载SampleCode
case $sample_needed in
[yY]* )  # clone sample

cd "${UNIVERSAL_OUTPUTFOLDER}/.."
FINAL_OUTPUTFOLDER="MApiSample-${SUFFIX_FOLER_NAME}"

echo "${ORANGEC}   ＃ 下载SampleCode ${NC}"
git clone $SAMPLE_GIT_REPO_ADDR
cp -R $UNIVERSAL_OUTPUTFOLDER/* MApiSample/
cd MApiSample

echo "${ORANGEC}   ＃ 设置BundleId => ${input_bundle_id} ${NC}"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${input_bundle_id}" MApiSample/MApiSample/Info.plist
echo "${ORANGEC}   ＃ 设置AppKey => ${input_app_key} ${NC}"
/usr/libexec/PlistBuddy -c "Set :MApiAppKey ${input_app_key}" MApiSample/MApiSample/Info.plist
echo "${ORANGEC}   ＃ 复制文档${NC}"
cp -R $TMPDIR/MApi/doc ./
rm -rf .git*
cd ..
mv MApiSample "${FINAL_OUTPUTFOLDER}"
open . ;;

[nN]* )  # open folder
cd "${UNIVERSAL_OUTPUTFOLDER}/.."
FINAL_OUTPUTFOLDER="MApi-${SUFFIX_FOLER_NAME}"
mv "${UNIVERSAL_OUTPUTFOLDER}" "${FINAL_OUTPUTFOLDER}"
open . ;;
esac

