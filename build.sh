#! /usr/bin/env bash
set -e

OUT=out

mkdir -p $OUT

printf 'building sd \n'
#nix-build '<nixpkgs/nixos>' --argstr system aarch64-linux -A config.system.build.sdImage -I nixos-config=sd-image.nix
nix build .#sd.config.system.build.sdImage

r1=$(readlink result)
echo $r1

printf 'building uboot \n'
nix build .#uboot

printf 'assembling image \n'
IMG=$(basename $r1/sd-image/*)
cp $r1/sd-image/$IMG $OUT/
cp result/*.img $OUT/
cp result/*.itb $OUT/
chmod -R u+w $OUT
ls -lah $OUT

dd if=$OUT/idbloader.img of=$OUT/$IMG conv=fsync,notrunc bs=512 seek=64
dd if=$OUT/u-boot.itb of=$OUT/$IMG conv=fsync,notrunc bs=512 seek=16384

#sfdisk --dump $OUT/$IMG

echo "Image built successfully?!"
echo ""
echo "Now burn the image with:"
echo "dd if=$OUT/$IMG of=/dev/mydev iflag=direct oflag=direct bs=16M status=progress"
echo "or compress it with:"
echo "tar -c -I 'xz -9 -T0' -f nanopi-nixos-$(date --rfc-3339=date).img.xz $OUT/$IMG"
