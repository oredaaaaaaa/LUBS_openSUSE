#!/bin/bash

set -e

# カスタムISOの設定
ISO_NAME="custom_opensuse.iso"
WORK_DIR="/tmp/opensuse_iso"
CHROOT_DIR="${WORK_DIR}/chroot"
IMAGE_DIR="${WORK_DIR}/image"
ISO_DIR="${WORK_DIR}/iso"
USERNAME="user"
PASSWORD="password"

# 必要なディレクトリを作成
mkdir -p ${CHROOT_DIR} ${IMAGE_DIR} ${ISO_DIR}
mkdir -p ${CHROOT_DIR}/usr ${CHROOT_DIR}/etc

# debootstrapで基本システムを作成
debootstrap --arch amd64 tumbleweed ${CHROOT_DIR} http://download.opensuse.org/tumbleweed/repo/oss/

# パッケージリストとロケール設定の読み込み
PACKAGES=$(cat packages.txt | xargs)
LOCALES=$(cat locale.txt)

# /config/airootfs/のカスタムファイルをchrootディレクトリにコピー
cp -r config/airootfs/* ${CHROOT_DIR}/

# chroot環境に入る
chroot ${CHROOT_DIR} /bin/bash <<EOT
set -e

# 必要なパッケージをインストール
zypper refresh
zypper install -y $PACKAGES

# ロケールの設定
for LOCALE in $LOCALES; do
    sed -i "s/^# \($LOCALE\)/\1/" /etc/locale.gen
done
locale-gen
update-locale LANG=ja_JP.UTF-8

# 一般ユーザーの作成とsudo権限の付与
useradd -m -G wheel -s /bin/bash ${USERNAME}
echo "${USERNAME}:${PASSWORD}" | chpasswd
echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}

# 必要な設定を行う
passwd -d root

# システムをクリーンアップ
zypper clean -a
rm -rf /tmp/*

# ユーザーのカスタムスクリプトを実行
source /config/user_script.sh
EOT

# カーネルとinitrdをコピー
cp ${CHROOT_DIR}/boot/vmlinuz-* ${IMAGE_DIR}/vmlinuz
cp ${CHROOT_DIR}/boot/initrd-* ${IMAGE_DIR}/initrd

# grubをセットアップ
mkdir -p ${ISO_DIR}/boot/grub
cat > ${ISO_DIR}/boot/grub/grub.cfg <<EOT
set timeout=10
set default=0

menuentry "Custom openSUSE" {
    linux /boot/vmlinuz
    initrd /boot/initrd
}
EOT

# squashfsイメージを作成
mksquashfs ${CHROOT_DIR} ${IMAGE_DIR}/filesystem.squashfs

# ISOファイルを作成
grub-mkrescue -o ${ISO_NAME} ${ISO_DIR} ${IMAGE_DIR}

echo "ビルドが正常に終了しました: ${ISO_NAME}"
