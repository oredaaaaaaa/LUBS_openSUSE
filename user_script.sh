#!/bin/bash
# ユーザーが自由に編集できるスクリプト
echo "ユーザーのカスタムスクリプトが実行されています。"

# Fcitx5の自動起動設定
echo "export XMODIFIERS=@im=fcitx5" >> /etc/profile.d/fcitx5.sh
echo "export GTK_IM_MODULE=fcitx5" >> /etc/profile.d/fcitx5.sh
echo "export QT_IM_MODULE=fcitx5" >> /etc/profile.d/fcitx5.sh
echo "export SDL_IM_MODULE=fcitx5" >> /etc/profile.d/fcitx5.sh
echo "export GLFW_IM_MODULE=fcitx5" >> /etc/profile.d/fcitx5.sh
