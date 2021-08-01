#!/bin/bash

set -e

ARTIFACT_ID=$1
EXCEPT=()

if [ "$2" = "release" ]
then
  NO_RELEASE="false"
  if [ -z "$VAGRANT_CLOUD_TOKEN" ]
  then
    echo "VAGRANT_CLOUD_TOKEN is not set"
    exit 1
  fi
else
  NO_RELEASE="true"
  EXCEPT="-except vagrant-cloud"
fi

function virtualbox_buster64() {
  isolist_output=`curl http://debian-cd.repulsive.eu/current/amd64/iso-cd/`
  file_name=`echo "$isolist_output" | grep -P '^.*debian-\d.*netinst.iso' | sed 's/^.*href="\(.*\)".*$/\1/'`
  os_version=`echo $file_name | sed 's/^debian-\(.*\)-amd64-netinst.iso/\1/'`
  patch_version=`date +"%Y%m%d"`
  version=$os_version-$patch_version
  iso_url=http://debian-cd.repulsive.eu/current/amd64/iso-cd/${file_name}
  iso_checksum=`curl http://debian-cd.repulsive.eu/current/amd64/iso-cd/SHA512SUMS | grep -P 'debian-\d.*-netinst.iso' | sed 's/^\([0-9a-f]\+\).*$/\1/'`
  mkdir target -p
  echo $version > target/version.txt

  packer build \
    -only="virtualbox-iso.buster64" \
    -var "debian-netinst-iso-url=$iso_url" \
    -var "debian-netinst-iso-checksum=$iso_checksum" \
    -var "build-version=$version" \
    -var "vagrant-cloud-token=$VAGRANT_CLOUD_TOKEN" \
    -var "no-release=$NO_RELEASE" \
    $EXCEPT \
    posts/00003-vagrant-box-for-buster64/template.pkr.hcl
}

function virtualbox_buster64_lightdm_mate() {
  version=`cat target/version.txt`
  echo $version
  packer build \
    -only="vagrant.buster64-lightdm-mate" \
    -var "build-version=$version" \
    -var "vagrant-cloud-token=$VAGRANT_CLOUD_TOKEN" \
    -var "no-release=$NO_RELEASE" \
    $EXCEPT \
    posts/00003-vagrant-box-for-buster64/template.pkr.hcl
}

case $ARTIFACT_ID in
  virtualbox_buster64)
    echo "Running build for vagrant buster64"
    virtualbox_buster64
    ;;
  virtualbox_buster64-lightdm-mate)
    virtualbox_buster64_lightdm_mate
    ;;
  *)
    echo "Which build? One of virtualbox_buster64, virtualbox_buster64-lightdm-mate"
esac
