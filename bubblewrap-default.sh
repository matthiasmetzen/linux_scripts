#!/bin/bash
set -euo pipefail
(
    bwrap \
	--ro-bind /sys /sys \
        --ro-bind /usr /usr \
	--symlink /usr/lib /lib \
	--ro-bind /lib64 /lib64 \
	--ro-bind /etc /etc \
	--ro-bind /bin /bin \
        --ro-bind /sbin /sbin \
	--dev /dev \
	--dev-bind /dev /dev \
	--proc /proc \
	--bind /run /run \
	--bind /mnt /mnt \
	--tmpfs /tmp \
	--bind /tmp/.X11-unix /tmp/.X11-unix \
	--setenv DISPLAY :0 \
	"$@"
)
