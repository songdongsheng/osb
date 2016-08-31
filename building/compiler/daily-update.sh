#!/bin/bash
# fn=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d%H%M%S)

# RancherOS.iso
cd /srv/archive/Linux
lms=`wget -q -S --spider -T 5 https://releases.rancher.com/os/latest/rancheros.iso 2>&1 | grep "^  Last-Modified:"`
ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O RancherOS-${ft}.iso https://releases.rancher.com/os/latest/rancheros.iso
wget -q -c -t 0 -T 5 -O RancherOS-${ft}.iso.checksums.txt https://releases.rancher.com/os/latest/iso-checksums.txt

# coreos_production_iso_image.iso
cd /srv/archive/Linux
lms=`wget -q -S --spider -T 5 http://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso 2>&1 | grep "^  Last-Modified:"`
ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O coreos_production_iso_image_${ft}.iso http://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso
wget -q -c -t 0 -T 5 -O coreos_production_iso_image_${ft}.iso.sig http://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso.sig

DEBIAN_WEEKLY_ROOT="/srv/archive/Linux"
DEBIAN_WEEKLY_PREFIX="http://cdimage.debian.org/cdimage/weekly-builds"
for os in amd64 arm64 armhf powerpc s390x; do
    url="${DEBIAN_WEEKLY_PREFIX}/${os}/iso-cd/debian-testing-${os}-netinst.iso"
    lms=`wget -S --spider -T 5 ${url} 2>&1 | grep "^  Last-Modified:"`
    [ "x${lms}x" = "xx" ] || (
        ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
        DEBIAN_WEEKLY_DIR=${DEBIAN_WEEKLY_ROOT}/debian-testing-${ft}
        mkdir -p ${DEBIAN_WEEKLY_DIR} && cd ${DEBIAN_WEEKLY_DIR}

        wget -c -t 0 -T 5 -O debian-testing-${os}-${ft}.iso ${url}

        wget -q -T 5 -O debian-testing-${os}-${ft}.SHA256SUMS ${DEBIAN_WEEKLY_PREFIX}/${os}/iso-cd/SHA256SUMS
        wget -q -T 5 -O debian-testing-${os}-${ft}.SHA256SUMS.asc ${DEBIAN_WEEKLY_PREFIX}/${os}/iso-cd/SHA256SUMS.sign
    )
done

# UltraEdit
# http://www.ultraedit.com/files/ue_english.exe
cd /srv/archive/Windows/UltraEdit
lms=`wget -q -S --spider -T 5 http://www.ultraedit.com/files/ue_english.exe 2>&1 | grep "^  Last-Modified:"`
ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O ue_v23_english_${ft}.exe http://www.ultraedit.com/files/ue_english.exe

# UltraEdit
# http://www.ultraedit.com/files/ue_english_64.exe
cd /srv/archive/Windows/UltraEdit
lms=`wget -q -S --spider -T 5 http://www.ultraedit.com/files/ue_english_64.exe 2>&1 | grep "^  Last-Modified:"`
ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O ue_v23_english_win64_${ft}.exe http://www.ultraedit.com/files/ue_english_64.exe

# UltraCompare
# http://www.ultraedit.com/files/uc_english.exe
cd /srv/archive/Windows/UltraEdit
lms=`wget -q -S --spider -T 5 http://www.ultraedit.com/files/uc_english.exe 2>&1 | grep "^  Last-Modified:"`
ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O uc_v16_english_${ft}.exe http://www.ultraedit.com/files/uc_english.exe

# UltraCompare
# http://www.ultraedit.com/files/uc_english_64.exe
cd /srv/archive/Windows/UltraEdit
lms=`wget -q -S --spider -T 5 http://www.ultraedit.com/files/uc_english_64.exe 2>&1 | grep "^  Last-Modified:"`
ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O uc_v16_english_win64_${ft}.exe http://www.ultraedit.com/files/uc_english_64.exe

# SkypeSetupFull.exe
# http://www.skype.com/go/getskype-windows [online]
# http://www.skype.com/go/getskype-full [offline]
cd /srv/archive/Windows/UltraEdit
lms=`wget -q -S --spider -T 5 http://www.skype.com/go/getskype-full 2>&1 | grep "^  Last-Modified:"`
ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O SkypeSetupFull-7.x-${ft}.exe http://www.skype.com/go/getskype-full

# BitTorrent Sync
# https://download-cdn.getsync.com/stable/linux-arm/BitTorrent-Sync_arm.tar.gz
# https://download-cdn.getsync.com/stable/windows/BitTorrent-Sync.exe
cd /srv/archive/Linux/sync
lms=`wget -q -S --spider -T 5 https://download-cdn.getsync.com/stable/windows64/BitTorrent-Sync_x64.exe 2>&1 | grep "^  Last-Modified:"`
fn=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O bittorrent_sync-windows_x64-${fn}.exe https://download-cdn.getsync.com/stable/windows64/BitTorrent-Sync_x64.exe

lms=`wget -q -S --spider -T 5 https://download-cdn.getsync.com/stable/linux-x64/BitTorrent-Sync_x64.tar.gz 2>&1 | grep "^  Last-Modified:"`
fn=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O bittorrent_sync-linux_x64-${fn}.tar.gz https://download-cdn.getsync.com/stable/linux-x64/BitTorrent-Sync_x64.tar.gz

lms=`wget -q -S --spider -T 5 https://download-cdn.getsync.com/stable/FreeBSD-x64/BitTorrent-Sync_freebsd_x64.tar.gz 2>&1 | grep "^  Last-Modified:"`
fn=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O bittorrent_sync-freebsd_x64-${fn}.tar.gz https://download-cdn.getsync.com/stable/FreeBSD-x64/BitTorrent-Sync_freebsd_x64.tar.gz

lms=`wget -q -S --spider -T 5 http://download-new.utorrent.com/endpoint/bittorrent/os/windows/track/stable 2>&1 | grep "^  Last-Modified:"`
ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O BitTorrent-7.9-${ft}.exe http://download-new.utorrent.com/endpoint/bittorrent/os/windows/track/stable

lms=`wget -q -S --spider -T 5 http://download.ap.bittorrent.com/track/stable/endpoint/utorrent/os/windows 2>&1 | grep "^  Last-Modified:"`
ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
wget -c -t 0 -T 5 -O uTorrent-3.4-${ft}.exe http://download.ap.bittorrent.com/track/stable/endpoint/utorrent/os/windows

# OpenBSD-snapshots-amd64.iso
# OpenBSD-snapshots-sparc64.iso
cd /srv/archive/BSD
for arch in amd64 sparc64; do
    lms=`wget -q -S --spider -T 5 http://ftp.openbsd.org/pub/OpenBSD/snapshots/${arch}/install60.iso 2>&1 | grep "^  Last-Modified:"`
    [ "x${lms}x" = "xx" ] || (
        ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d%H%M)
        wget -c -t 0 -T 5 -O OpenBSD-snapshots-${arch}-${ft}-install60.iso http://ftp.openbsd.org/pub/OpenBSD/snapshots/${arch}/install60.iso
        wget -q -c -t 0 -T 5 -O OpenBSD-snapshots-${arch}-${ft}.SHA256.sig    http://ftp.openbsd.org/pub/OpenBSD/snapshots/${arch}/SHA256.sig
    )
done

AzureFeed="https://dotnetcli.blob.core.windows.net/dotnet"

for os in win-x64 debian-x64 ubuntu-x64 centos-x64 rhel-x64 ubuntu.16.04-x64; do
    if [ "${os}" = "win-x64" ] ; then
        SUFFIX="zip"
    else
        SUFFIX="tar.gz"
    fi

    SpecificVersion=`wget -q -O - https://dotnetcli.blob.core.windows.net/dotnet/Sdk/rel-1.0.0/latest.version 2>&1 | grep ^1\\.0\\.0 | tr -cd '[[:alnum:]-_.]'`
    url="${AzureFeed}/Sdk/${SpecificVersion}/dotnet-dev-${os}.${SpecificVersion}.${SUFFIX}"
    echo ${url}
    lms=`wget -S --spider -T 5 ${url} 2>&1 | grep "^  Last-Modified:"`
    [ "x${lms}x" = "xx" ] || (
        CLI_DIR="/srv/archive/CLR/dotnet-${SpecificVersion}"
        mkdir -p ${CLI_DIR}; cd ${CLI_DIR}

        ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d%H%M)
        wget -q -c -t 0 -T 5 -O dotnet-cli-${os}.${SpecificVersion}-${ft}.${SUFFIX} ${url}
    )
done

UBUNTU_DAILY_ROOT="/srv/archive/Linux"
UBUNTU_DAILY_PREFIX="http://cdimage.ubuntu.com/ubuntu-server/xenial/daily/current"
for os in amd64 powerpc s390x; do
   for ext in iso squashfs; do
        url="${UBUNTU_DAILY_PREFIX}/xenial-server-${os}.${ext}"
        lms=`wget -S --spider -T 5 ${url} 2>&1 | grep "^  Last-Modified:"`
        [ "x${lms}x" = "xx" ] || (
            ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m)
            UBUNTU_DAILY_DIR=${UBUNTU_DAILY_ROOT}/ubuntu-1604-${ft}
            mkdir -p ${UBUNTU_DAILY_DIR} && cd ${UBUNTU_DAILY_DIR}

            ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
            wget -c -t 0 -T 5 -O ubuntu-16.04-server-${os}-${ft}.${ext} ${url}

            lms=`wget -S --spider -T 5 ${UBUNTU_DAILY_PREFIX}/SHA256SUMS.gpg 2>&1 | grep "^  Last-Modified:"`
            ft=$(TZ=UTC /bin/date --date="${lms:17}" +%Y%m%d)
            wget -q -T 5 -O ubuntu-16.04-server-${ft}.SHA256SUMS ${UBUNTU_DAILY_PREFIX}/SHA256SUMS
            wget -q -T 5 -O ubuntu-16.04-server-${ft}.SHA256SUMS.asc ${UBUNTU_DAILY_PREFIX}/SHA256SUMS.gpg
        )
   done
done
