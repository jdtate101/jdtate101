neofetch
sudo aptitude update --no-gui && sudo aptitude safe-upgrade -y --no-gui && sudo aptitude autoclean -y --no-gui
echo "*********************"
echo "*                   *"
echo "*   Updating k3s    *" 
echo "*                   *"
echo "*********************"
ssh -p 22 jtate@192.168.1.11 "neofetch && sudo aptitude update --no-gui && sudo aptitude safe-upgrade -y --no-gui && sudo aptitude autoclean -y --no-gui"
echo "*********************"
echo "*                   *"
echo "* Updating k3s-test *"
echo "*                   *"
echo "*********************"
ssh -p 22 jtate@192.168.1.3 "neofetch && sudo aptitude update --no-gui && sudo aptitude safe-upgrade -y --no-gui && sudo aptitude autoclean -y --no-gui"
echo "*********************"
echo "*                   *"
echo "*  Updating sftpgo  *"
echo "*                   *"
echo "*********************"
ssh -p 22 jtate@192.168.1.7 "neofetch && sudo aptitude update --no-gui && sudo aptitude safe-upgrade -y --no-gui && sudo aptitude autoclean -y --no-gui"
echo "*********************"
echo "*                   *"
echo "*   Updating Emby   *"
echo "*                   *"
echo "*********************"
ssh -p 22 jtate@192.168.1.6 "neofetch && sudo aptitude update --no-gui && sudo aptitude safe-upgrade -y --no-gui && sudo aptitude autoclean -y --no-gui"
echo "*********************"
echo "*                   *"
echo "*  Updating Docker  *"
echo "*                   *"
echo "*********************"
ssh -p 22 jtate@192.168.1.8 "neofetch && sudo aptitude update --no-gui && sudo aptitude safe-upgrade -y --no-gui && sudo aptitude autoclean -y --no-gui"
echo "*********************"
echo "*                   *"
echo "*  Updating Harbor  *"
echo "*                   *"
echo "*********************"
ssh -p 22 jtate@192.168.1.5 "neofetch && sudo aptitude update --no-gui && sudo aptitude safe-upgrade -y --no-gui && sudo aptitude autoclean -y --no-gui"
echo "*********************"
echo "*                   *"
echo "* Updating Useless  *"
echo "*                   *"
echo "*********************"
ssh -p 22 jtate@192.168.1.10 "neofetch && sudo aptitude update --no-gui && sudo aptitude safe-upgrade -y --no-gui && sudo aptitude autoclean -y --no-gui"
echo "*********************"
echo "*                   *"
echo "* Updating kubevirt *"
echo "*                   *"
echo "*********************"
ssh -p 22 jtate@192.168.1.13 "neofetch && sudo aptitude update --no-gui && sudo aptitude safe-upgrade -y --no-gui && sudo aptitude autoclean -y --no-gui"
