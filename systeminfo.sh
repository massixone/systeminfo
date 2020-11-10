#!/bin/bash
#
# -*- coding:utf-8, indent=tab, tabstop=4 -*-
#
#    smartdbbackup is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#   @package    systeminfo.sh
#   @module     Main
#   @author     Massimo Di Primio   massimo@diprimio.com
#   @license    GNU General Public License version 3, or later
#
#    _  _                                 _____                               ______                    
#    | /               /                  /    )         /                      /                  /    
# ---|------__--_/_---/----__---__-------/----/----__---/__-----------__-------/-------__----__---/-----
#   /|    /   ) /    /   /   ) (_ `     /    /   /___) /   ) /   /  /   )     /      /   ) /   ) /      
# _/_|___(___(_(_ __/___(___(_(__)_____/____/___(___ _(___/_(___(__(___/_____/______(___/_(___/_/_______
#                                                                     /                                 
#                                                                 (_ /                                  
# Revision History
#
# 1.0.4		dpm	Added 'dmidecode' output to file 'sysinfo-dmidecode.txt'
#			sysinfo.txt and sysinfo-dmidecode.txt packed in a zip file 'sysinfo.zip'
# 1.0.5		dpm	Added command 'lsblk' wether the system recognizes the command or not
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONFIGURATION
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
VERSION="1.0.7"
TMPARG=$0
#BN=$(basename $0)
BN=${TMPARG##*/}		# `basename` can be deprecated in some systems
DN=${TMPARG%/*}			# `dirname` can be deprecated in some systems
cd ${DN}
OFILE="./xatlas-$(hostname)-${BN/sh/txt}"
OFILE_DMIDECODE="xatlas-$(hostname)-dmidecode-${BN/sh/txt}"
ZIPFILE="./xatlas-$(hostname)-${BN/sh/zip}"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MAIN
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Check for allowed users
if [ ${USER} != "root" ]; then
    echo "Error! You must be logged in as user 'root' to run this utility."
    kill $$
fi

# Prepare log file
cp -f /dev/null ${OFILE}
cp -f /dev/null ${OFILE_DMIDECODE}
touch $OFILE
echo -en "" > $OFILE
exec > >(tee ${OFILE}) 2>&1

# Write some useful information on log file header
echo -en "\n===== XATLAS DEBUG TOOL - Version: ${VERSION} =====\n"
echo -en "Output file is: [${OFILE}]\n"
echo -en "Execution date: $(date), as user: [${USER}] from TTY [$(tty)]\n"

#
# Go though all commands withi sections
#
SECTION="SYSTEM";echo -en "\n\n===== SECTION: ${SECTION} =====\n"
MYCMD='uname -a'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='hostid'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='runlevel'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='cat /etc/*release*'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='free'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='cat /proc/cpuinfo'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='R=$(runlevel | cut -d " " -f 2);chkconfig --list | grep "${R}:on" | sort'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='cat /etc/ntp.conf | grep -v "^#" | egrep "server|restrict"'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='crontab -u root -l'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='crontab -u axsuser -l'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"


SECTION="NETWORK";echo -en "\n\n===== SECTION: ${SECTION} =====\n"
MYCMD='ifconfig -a'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='ip a'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='route -n'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='hostname'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='cat /etc/hosts'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='cat /etc/resolv.conf'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='netstat -plantu'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

SECTION="STORAGE";echo -en "\n\n===== SECTION: ${SECTION} =====\n"
MYCMD='fdisk -l' 
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"	#${MYCMD}
MYCMD='blkid'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"
MYCMD='lsblk'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"
MYCMD='df -h'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"
MYCMD='swapon -s'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"
MYCMD='mount | column -t'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

# LVM
MYCMD='pvscan'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"
MYCMD='vgscan'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"
MYCMD='lvscan'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='pvdisplay'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"
MYCMD='vgdisplay'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"
MYCMD='lvdisplay'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"


SECTION="XATLAS";echo -en "\n\n===== SECTION: ${SECTION} =====\n"
MYCMD='ps -ef | egrep "wsm|fmc"'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"	#ps -ef | egrep "wsm|fmc"

MYCMD='chkconfig --list | egrep "wsm|fmc"'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"	#chkconfig --list | egrep "wsm|fmc"

MYCMD='ls -l /opt/axs'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='ls -l /opt/axs/release'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='(echo "V" ; sleep 1) | telnet localhost 8188 | strings'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='su - axsuser -c "cat .netrc"'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='id -a axsuser'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD='grep axsuser /etc/passwd'
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

SECTION="DATABASE";echo -en "\n\n===== SECTION: ${SECTION} =====\n"
MYCMD="psql -V"
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD="psql -h localhost -U axsuser AXS_DB -c '\l+'"
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD="psql -h localhost -U axsuser AXS_DB -c \"SELECT * FROM pg_catalog.pg_database;\""
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD="psql -h localhost -U axsuser AXS_DB -c \"SELECT datname, age(datfrozenxid) FROM pg_database;\""
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD="psql -h localhost -U axsuser AXS_DB -c \"SELECT pg_size_pretty( pg_database_size('AXS_DB'))\""
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

MYCMD="psql -h localhost -U axsuser AXS_DB -c 'SELECT * FROM install_keys'"
echo -en "\n--> Command: [${MYCMD}]\n"; eval "$MYCMD"

echo -en "\n--> Command: [dmidecode]\n"
dmidecode > ${OFILE_DMIDECODE} 2>&1

echo -en "\n========== ALL COMMANDS DONE ==========\n"
echo -en "Zipping all files together into file: ${ZIPFILE}"
zip ${ZIPFILE} ${OFILE} ${OFILE_DMIDECODE}

echo "Program terminated!"

#
echo -en "\nend-of-file\n"
