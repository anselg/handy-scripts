#! /bin/bash

# Export environment variables
echo  "----->Setting up variables"
export linux_version=4.4.1
export aufs_version=4.4

# Download essentials
echo  "----->Downloading Linux kernel"
wget --no-check-certificate https://www.kernel.org/pub/linux/kernel/v4.x/linux-$linux_version.tar.gz
tar xf linux-$linux_version.tar.gz
export linux_tree="linux-${linux_version}"

# yeah, need to rethink this...
wget --no-check-certificate https://www.kernel.org/pub/linux/kernel/projects/rt/4.4/patch-4.4.1-rt6.patch.gz
gunzip patch-4.4.1-rt6.patch

# Patch rt kernel
cd $linux_tree
patch -p1 < ../patch-4.4.1-rt6.patch

# Patch aufs
echo  "----->Patching aufs kernel"
git clone https://github.com/sfjro/aufs4-standalone.git aufs-$aufs_version
export aufs_root="aufs-${aufs_version}"

cd $aufs_root
git checkout origin/aufs$aufs_version
patch -p1 < $aufs_root/aufs4-kbuild.patch && \
patch -p1 < $aufs_root/aufs4-base.patch && \
patch -p1 < $aufs_root/aufs4-mmap.patch && \
patch -p1 < $aufs_root/aufs4-standalone.patch
cp -r $aufs_root/Documentation $linux_tree
cp -r $aufs_root/fs $linux_tree
cp $aufs_root/include/uapi/linux/aufs_type.h $linux_tree/include/uapi/linux/
cp $aufs_root/include/uapi/linux/aufs_type.h $linux_tree/include/linux/
