#!/bin/bash

toasterdir='toasters/'

showhelp () {
cat << EOF
Usage: $0 <action> [toaster]
$0 list              - List Available toasters
$0 install <toaster> - Install the specified toaster (it will overwrite Puppetfile, manifests/init.pp and the modules directory
$0 run <toaster>     - Install and run the specified toaster on the running Vagrant boxes
$0 clean             - Cleans everything: Beware: this will delete Puppetfile, manifests/init.pp and the modules directory
$0 status            - Show active toaster setup
EOF
}

SETCOLOR_NORMAL="echo -en \\033[0;39m"
SETCOLOR_TITLE="echo -en \\033[0;35m"
SETCOLOR_BOLD="echo -en \\033[0;1m"

echo_title () {
 echo
 $SETCOLOR_BOLD ; echo $1 ; $SETCOLOR_NORMAL
}

list_toaster() {
  echo_title "Available toasters"
  ls -1 $toasterdir
}

install_toaster() {
  echo_title "Copying toaster files"  
  cp -f $toasterdir/$toaster/Puppetfile Puppetfile
  cp -f $toasterdir/$toaster/init.pp manifests/init.pp
  echo_title "Running librarian-puppet install"  
  librarian-puppet install
}

run_toaster() {
  echo_title "Running vagrant provision"
  vagrant provision
}

clean() {
  echo "I'm going to delete: the modules/ dir, manifests/init.pp and Puppetfile... Are you Sure? (y/N)"
  read answer
  if [ "x$answer" == "xy" ] ; then
    echo_title "Removing modules dir, manifests/init.pp and Puppetfile"
    rm -rf modules/
    rm -f Puppetfile
    rm -f manifests/init.pp
  fi
}

status() {
  echo_title "Installed Modules"
  librarian-puppet show
  echo_title "Content of manifests/init.pp"
  cat manifests/init.pp
}

while [ $# -gt 0 ]; do
  case "$1" in
    list)
      action=$1
      shift
      ;;
    clean)
      action=$1
      shift
      ;;
    status)
      action=$1
      shift
      ;;
    install)
      action=$1
      toaster=$2
      shift 2
      ;;
    run)
      action=$1
      toaster=$2
      shift 2
      ;;
    *)
      showhelp
      exit
      ;;
  esac
done

case $action in 
  list) list_toaster ;;
  install) install_toaster ;;
  clean) clean ;;
  status) status ;;
  run ) install_toaster ; run_toaster ;;
  * ) showhelp ;;
esac

