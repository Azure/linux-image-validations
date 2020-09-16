#!/bin/sh

if [ -f /etc/oracle-release ]; then
    if grep -q 'Oracle Linux Server release 6.*' /etc/oracle-release; then
        VERSION=`sed "s/[^0-9]*//g" /etc/oracle-release`
	    if [ `uname -m` = "x86_64" -a $VERSION -ge 64 ]; then
            OS="OL6-64"
        fi
    elif grep -q 'Oracle Linux Server release 7.*' /etc/oracle-release; then
        if [ `uname -m` = "x86_64" ]; then
            OS="OL7-64"
        fi
    elif grep -q 'Oracle Linux Server release 8.*' /etc/oracle-release; then
        if [ `uname -m` = "x86_64" ]; then
            OS="OL8-64"
        fi
    fi
elif [ -f /etc/redhat-release ]; then
    if grep -q 'Red Hat Enterprise Linux Server release 5.*' /etc/redhat-release || \
        grep -q 'CentOS release 5.*' /etc/redhat-release; then
	VERSION=`sed "s/[^0-9]*//g" /etc/redhat-release`
	if [ `uname -m` = "x86_64" -a $VERSION -ge 52 -a $VERSION -le 511 ]; then
            OS="RHEL5-64"
        fi
    elif grep -q 'Red Hat Enterprise Linux Server release 6.*' /etc/redhat-release || \
        grep -q 'Red Hat Enterprise Linux Workstation release 6.*' /etc/redhat-release || \
        grep -q 'CentOS Linux release 6.*' /etc/redhat-release ||
        grep -q 'CentOS release 6.*' /etc/redhat-release; then
	if [ `uname -m` = "x86_64" ]; then
            OS="RHEL6-64"
        fi
    elif grep -q 'Red Hat Enterprise Linux Server release 7.*' /etc/redhat-release || \
        grep -q 'Red Hat Enterprise Linux Workstation release 7.*' /etc/redhat-release || \
        grep -q 'CentOS Linux release 7.*' /etc/redhat-release; then
	if [ `uname -m` = "x86_64" ]; then
            OS="RHEL7-64"
        fi
    elif grep -q 'Red Hat Enterprise Linux release 8.*' /etc/redhat-release || \
        grep -q 'CentOS Linux release 8.*' /etc/redhat-release; then
	if [ `uname -m` = "x86_64" ]; then
            OS="RHEL8-64"
        fi
    fi
elif [ -f /etc/SuSE-release ]; then
    if grep -q 'VERSION = 11' /etc/SuSE-release && grep -q 'PATCHLEVEL = 3' /etc/SuSE-release; then
	if [ `uname -m` = "x86_64" ]; then
            OS="SLES11-SP3-64"
        fi
    elif grep -q 'VERSION = 11' /etc/SuSE-release && grep -q 'PATCHLEVEL = 4' /etc/SuSE-release; then
	if [ `uname -m` = "x86_64" ]; then
            OS="SLES11-SP4-64"
        fi
    fi
    if grep -q 'VERSION = 12' /etc/SuSE-release; then
        if [ `uname -m` = "x86_64" ]; then
            OS="SLES12-64"
        fi
    elif grep -q 'VERSION="15' /etc/SuSE-release; then
        if [ `uname -m` = "x86_64" ]; then
            OS="SLES15-64"
        fi
    fi
elif [ -f /etc/os-release ] && grep -q 'SLES' /etc/os-release; then
    if grep -q 'VERSION="15' /etc/os-release; then
        if [ `uname -m` = "x86_64" ]; then
            OS="SLES15-64"
        fi
    fi
elif [ -f /etc/lsb-release ] ; then
    if grep -q 'DISTRIB_RELEASE=14.04' /etc/lsb-release ; then
	if [ `uname -m` = "x86_64" ]; then
            OS="UBUNTU-14.04-64"
        fi
    elif grep -q 'DISTRIB_RELEASE=16.04' /etc/lsb-release ; then
	if [ `uname -m` = "x86_64" ]; then
            OS="UBUNTU-16.04-64"
        fi
    elif grep -q 'DISTRIB_RELEASE=18.04' /etc/lsb-release ; then
	if [ `uname -m` = "x86_64" ]; then
            OS="UBUNTU-18.04-64"
        fi
    elif grep -q 'DISTRIB_RELEASE=20.04' /etc/lsb-release ; then
	if [ `uname -m` = "x86_64" ]; then
            OS="UBUNTU-20.04-64"
        fi
    fi
elif [ -f /etc/debian_version ]; then
    if grep -q '^7.*' /etc/debian_version; then
        if [ `uname -m` = "x86_64" ]; then
            OS="DEBIAN7-64"
        fi
    elif grep -q '^8.*' /etc/debian_version; then
        if [ `uname -m` = "x86_64" ]; then
            OS="DEBIAN8-64"
        fi
    elif grep -q '^9.*' /etc/debian_version; then
        if [ `uname -m` = "x86_64" ]; then
            OS="DEBIAN9-64"
        fi
    fi
fi

if [ $# -gt 0 ]
then
    echo $OS
fi
