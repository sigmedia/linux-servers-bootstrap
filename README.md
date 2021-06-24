# Bootstrapping scripts for SIGMEDIA Linux servers

This repository contains the scripts to bootstrap the SIGMEDIA Linux servers.
The assumed distribution is **Arch Linux** and the scripts configure the following parts:
  - *Active Directory* in order to use the MEE.TCD.IE credentials
  - *Docker*
  - *NVIDIA/CUDA/CUDNN* to support GPU

# How to use the scripts

It follows the classic installation pattern of Arch Linux:
  1. execute the different steps up to the **arch-chroot** (included)
     - for the pacstrap command append git to be able to clone the repository
  2. clone this repository: git clone https://github.com/sigmedia/linux-servers-bootstrap.git
  3. go to the directory of the cloned repository and call the script `00_pre_reboot_install.sh`
     - the script takes two arguments: the hostname (e.g. sigXXX) and the hard drive /dev path to install the bootloader
  4. reboot
  5. go to the directory of the cloned repository and call the script `01_post_reboot_install.sh`
  6. reboot one last time

# Some current hardcoded information

Only users from the group **supermedia** have sudo permissions and docker capabilities.
