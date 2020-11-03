#!/bin/sh

DIR=`dirname $0`
OS=`${DIR}/OS_details.sh 1`

if lsmod | grep -iq involflt; then
    echo "involflt module is already loaded"
    exit 1
fi

KERNEL_MINOR_VERSION=`uname -r | cut -d"-" -f2 | cut -d"." -f1`
echo "Current running kernel: `uname -r` and minor version is $KERNEL_MINOR_VERSION"
echo "OS is $OS"
case $OS in
    RHEL7-64)
        RHEL7_KMV_BASE="123"
        RHEL7_KMV_U3="514"
        RHEL7_KMV_U4="693"

        if [ $KERNEL_MINOR_VERSION -lt "$RHEL7_KMV_U4" ]; then
            if [ $KERNEL_MINOR_VERSION -lt "$RHEL7_KMV_U3" ]; then
                minorVersion=${RHEL7_KMV_BASE}
            else
                minorVersion=${RHEL7_KMV_U3}
            fi
        else
            minorVersion=${RHEL7_KMV_U4}
        fi

        drvName="involflt.ko.3.10.0-${minorVersion}.el7.x86_64"
        ;;

    RHEL8-64)
        RHEL8_KMV_V0="80"
        RHEL8_KMV_V1="147"
        RHEL8_KMV_V2="193"

        KERNEL_COPY_VERSION=""
        case $KERNEL_MINOR_VERSION in
            $RHEL8_KMV_V0)
                minorVersion=$RHEL8_KMV_V0
                ;;
            *)
                minorVersion=$RHEL8_KMV_V1
                ;;
        esac

        drvName="involflt.ko.4.18.0-${minorVersion}.el8.x86_64"
        ;;

    *)
        echo "Unable to identify the OS $OS"
        exit 1
esac

echo "Downloading the driver $drvName"
wget https://https://rheldriverssa.blob.core.windows.net/involflt-`tr [A-Z] [a-z] <<< $OS`/$drvName
if [ ! -e "$drvName" ]; then
    echo "Downloading of $drvName from https://v2agqldevsa.blob.core.windows.net/involflt-`tr [A-Z] [a-z] <<< $OS`/$drvName failed"
    exit 1
fi

kerPath="/lib/modules/`uname -r`/kernel/drivers/char/"
echo "Copying the driver $drvName to the path $kerPath"
cp -f $drvName ${kerPath}/involflt.ko
if [ $? -ne 0 ]; then
    echo "Unable to copy the driver"
    exit 1
fi

echo "Running depmod"
depmod
if [ $? -ne 0 ]; then
    echo "depmod did not succeed"
    exit 1
fi

echo "Loading the involflt driver"
modprobe involflt
if lsmod | grep -iq involflt; then
    echo "involflt module loaded successfully"
else
    echo "involflt module is not loaded"
    exit 1
fi

exit 0
