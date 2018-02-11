pkgname=nvidia-bumblebee-applet
srcdir=$(pwd)
cd /usr/lib
if [ -d $pkgname ] 
then
  echo "Removing old applet"
  rm -rf ${pkgname}
fi
cp -dpr --no-preserve=ownership ${srcdir} ${pkgname}
echo "Removing .git files"
cd ${pkgname}
rm -f .gitignore
rm -rf .git
echo "Removing dev files"
rm -f PKGBUILD
rm -f README.md

cp -dpr --no-preserve=ownership ./icons/*.svg /usr/share/icons/
cp -dpr --no-preserve=ownership ./icons/nvidia-bumblebee.png /usr/share/icons/
rm -rf icons

cp -dpr --no-preserve=ownership ./etc/xdg/autostart/nvidia-bumblebee.desktop /etc/xdg/autostart/nvidia-bumblebee.desktop
rm -rf etc
