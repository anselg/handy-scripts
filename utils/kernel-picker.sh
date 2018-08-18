#! /bin/bash
set -eu

#
# Globals
#

distro=$(lsb_release -sd | tr -d \")

kernelstring=$(grep "menuentry" /boot/grub/grub.cfg | grep -v "recovery" | \
               sed -n "s/\s*menuentry '${distro}, with Linux \(.*\)' --class .*/\1/p")

kernels=()
for kernel in ${kernelstring[@]}; do
  kernels+=("${kernel}")
done


#
# Functions
#

show_error() {
  echo -e "\033[1;31m$@\033[m" 1>&2
}
show_info() {
  echo -e "\033[1;32m$@\033[0m"
}
show_warning() {
  echo -e "\033[1;33m$@\033[0m"
}
show_question() {
  echo -e "\033[1;34m$@\033[0m"
}
ask_question() {
  read -p $'\033[1;34m'"$@ "$'\033[0m' var
  echo "$var"
}
show_success() {
  echo -e "\033[1;35m$@\033[0m"
}
show_header() {
  echo -e "\033[1;36m$@\033[0m"
}
show_listitem() {
  echo -e "\033[0;37m$@\033[0m"
}

function set_default_kernel() {
  show_info "Setting default kernel to $1."
  sudo sed -i.bak.$(date +%Y%m%d-%I%M%S) \
    "s/GRUB_DEFAULT=.*/GRUB_DEFAULT='Advanced options for ${distro}>${distro}, with Linux $1'/g" \
    /etc/default/grub
  show_success "Done."
  show_info "The old config file is backed up in /etc/default/."
  echo

  show_info "Updating /boot/grub/grub.cfg to reflect new defaults."
  sudo update-grub
  show_success "Done."
} 


#
# Main
#

show_question "Which kernel should be the default?"
select kernel in "${kernels[@]}"; do
  case "$kernel" in
    '4.15.0-32-generic')
      set_default_kernel "$kernel"
      break
      ;;
    '3.8.13-xenomai-2.6.4-aufs'|'3.8.13-xenomai-2.6.4')
      set_default_kernel "$kernel"
      break
      ;;
    '3.14.17-xenomai-2.6.4-aufs'|'3.14.17-xenomai-2.6.4')
      set_default_kernel "$kernel"
      break
      ;;
    '3.14.44-xenomai-2.6.5-aufs'|'3.14.44-xenomai-2.6.5')
      set_default_kernel "$kernel"
      break
      ;;
    '4.9.51-xenomai-3.0.5-aufs'|'4.9.51-xenomai-3.0.5')
      set_default_kernel "$kernel"
      break
      ;;
    *)
      show_error "Kernel $kernel is not supported."
      show_warning "Permitted kernels must be manually added to this script."
      break
      ;;
  esac
done