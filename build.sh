#!/bin/bash

#
# Lemon build script
#
# (c) 2024- Yamanote_F2L Co Ltd.
#
# このビルドツールは開発者がとにかくSforzatoLinux用に適当に作っただけです。
#
# 適当とはいえ、kiwi-ngをベースにしていてビルドをより簡単にしています。
#


#必要なパッケージのインストール
sudo zypper install -y python3-kiwi python3-xmltodict git


#必要なディレクトリの作成
mkdir out
mkdir work

#kiwi-ngをGithubからクローン(ダウンロード)する
#(レシピに関してはここから2行下のコマンドをコメントアウトさえすれば自分で用意することができます。)
git clone https://github.com/OSInside/kiwi.git
git clone https://github.com/SforzatoLinux/iso-maker/


#SforzatoLinuxのレシピを作業用ディレクトリにコピーする
cp iso-maker/test-gui-04 -r work


#不要なディレクトリの削除
sudo rm -rf iso-maker


#kiwi-ngを使ってビルドする
sudo kiwi-ng system build --description work/test-gui-04 --target-dir out
