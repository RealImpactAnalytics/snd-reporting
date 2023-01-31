#!/usr/bin/env bash

# ON mac OSX
# brew install coreutils findutils
# echo 'PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"' >> ${HOME}/.bash_profile
# source ${HOME}/.bash_profile

set -e

tarball=${1}
SSH_CONNECTION=${2}
PARTS_SIZE=${3:-500m}

split_dir="${PWD}/tmp_tarball_split"
remote_tmp_splitted_pkg="/tmp/riaktr-docker-images-package-splitted"

if [[ -z "${tarball}" ]]; then
    echo "please provide path to a target tarball to upload!"
    exit 1
fi

# Check if file exists
if [[ ! -f ${tarball} ]]; then
    echo "please provide path to an existing target tarball to upload, ${tarball} doesn't exist"
    exit 1
fi

if [[ -z "${SSH_CONNECTION}" ]]; then
    echo "please provide a valid ssh connection (ssh config alias or full ssh connection <user>@<remote_host>)"
    exit 1
fi

echo "uploading tarball $(du -skh ${tarball})using splits of ${PARTS_SIZE}"

local_tarball_checksum=$(md5sum ${tarball} | cut -d " " -f1)

# Create working dir
rm -rf ${split_dir}
mkdir -p ${split_dir}

# Split in multipart
split -b ${PARTS_SIZE} ${tarball} ${split_dir}/splitted-package_

# Upload in //
ssh ${SSH_CONNECTION} "rm -rf ${remote_tmp_splitted_pkg}"
ssh ${SSH_CONNECTION} "mkdir -p ${remote_tmp_splitted_pkg}"
for file in $(ls ${split_dir}/splitted-package_*) ; do
     rsync -azvvP $file ${SSH_CONNECTION}:${remote_tmp_splitted_pkg}/. && echo "upload of part ${file} done to remote server" &
done

wait

echo "all parts are uploaded"

echo "merge back all tarball parts into initial tarball"
remote_tarball=$(echo "${tarball}" | rev | cut -d "/" -f1 | rev)
ssh ${SSH_CONNECTION} "rm -f ${remote_tarball}"
ssh ${SSH_CONNECTION} "cat ${remote_tmp_splitted_pkg}/* > /tmp/${remote_tarball}"
ssh ${SSH_CONNECTION} "rm -rf ${remote_tmp_splitted_pkg}"

rm -rf "${split_dir}"

remote_tarball_checksum=$(ssh ${SSH_CONNECTION} md5sum /tmp/${remote_tarball} | cut -d " " -f1)

if [[ "${local_tarball_checksum}" != "${remote_tarball_checksum}" ]]; then
    echo "Something went wrong during upload. The uploaded package is corrupted (checksums differ)"
    exit 1
fi

echo "You can now load the docker images tarball using docker load -i /tmp/${remote_tarball}, from the target server"
echo ""
