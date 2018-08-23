#! /bin/bash
set -eu

#
# Color prompts
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


#
# Functions
#

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

distro=$(lsb_release -si)

# Get list of kernels from grub config file.
kernelstring=$(grep "menuentry" /boot/grub/grub.cfg | \
               grep -v "recovery" | grep -v "fallback" | \
               sed -n "s/\s*menuentry '${distro}, with Linux \([0-9\.]\+-xenomai-[0-9\.]\+[-aufs]*\)/\1/p")
if [[ "${kernelstring}" = "" ]]; then
  show_error "Unable to get kernel list. Exiting."
  exit 2
fi
kernels=()
for kernel in ${kernelstring[@]}; do
  kernels+=("${kernel}")
done

show_question "Which kernel should be the default?"
select kernel in "${kernels[@]}"; do
  set_default_kernel "$kernel"
  break
done
