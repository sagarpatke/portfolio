#!/bin/bash

set -e

ARTIFACT_ID=$1

function virtualbox_buster64() {
  isolist_output=`curl http://debian-cd.repulsive.eu/current/amd64/iso-cd/`
  file_name=`echo "$isolist_output" | grep -P '^.*debian-\d.*netinst.iso' | sed 's/^.*href="\(.*\)".*$/\1/'`
  iso_url=http://debian-cd.repulsive.eu/current/amd64/iso-cd/${file_name}
  iso_checksum=`curl http://debian-cd.repulsive.eu/current/amd64/iso-cd/SHA512SUMS | grep -P 'debian-\d.*-netinst.iso' | sed 's/^\([0-9a-f]\+\).*$/\1/'`

  packer build \
    -only="virtualbox-iso.buster64" \
    -var "debian-netinst-iso-url=$iso_url" \
    -var "debian-netinst-iso-checksum=$iso_checksum" \
    posts/00003-vagrant-box-for-buster64/template.pkr.hcl
}

function virtualbox_buster64_lightdm_mate() {
  packer build -only="vagrant.buster64-lightdm-mate" posts/00003-vagrant-box-for-buster64/template.pkr.hcl
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
