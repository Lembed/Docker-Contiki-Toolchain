#!/bin/bash

DOCKER_NAME=contiki-os-toolchain
USER_NAME=root
IMAGE_NAME=image-$USER_NAME
DOCKER_PATH=`which docker.io || which docker`
SSH_PATH=`which ssh`
VOLUME_MOUNT=/home/${USER_NAME}/workspace/:/home/${USER_NAME}/workspace


launcher_start () {

	# 1. docker daemon running?
  # we send stderr to /dev/null cause we don't care about warnings,
  # it usually complains about swap which does not matter
  test=`$DOCKER_PATH info 2> /dev/null`

  if [[ $? -ne 0 ]] ; then
    echo "Cannot connect to the docker daemon - verify it is running and you have access"
    exit 1
  fi

   # Disk space
  free_disk="$(df /var | tail -n 1 | awk '{print $4}')"
  if [ "$free_disk" -lt 1000 ]; then
    echo "WARNING: You must have at least 1GB of *free* disk space to run ."
    echo
    echo "Please free up some space, or expand your disk, before continuing."
    exit 1
  fi

 }

check_ports () {
  local valid=$(netstat -tln | awk '{print $4}' | grep ":${1}\$")

  if [ -n "$valid" ]; then
    echo "Launcher has detected that port ${1} is in use."
    echo ""   
    exit 1
  fi
}

install_docker () {

  echo "Docker is not installed, you will need to install Docker "
  echo "Please visit https://docs.docker.com/installation/ for instructions on how to do this for your system"
  echo
  echo "If you are running Ubuntu Trusty or later, you can try the following:"
  echo

  echo "sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D"
  echo "sudo sh -c \"echo deb https://apt.dockerproject.org/repo ubuntu-$(lsb_release -sc) main > /etc/apt/sources.list.d/docker.list\""
  echo "sudo apt-get update"
  echo "sudo apt-get install docker-engine"

  exit 1
}

# echo the help text
usage () {
  echo "Usage: launcher.sh COMMAND"
  echo "Commands:"
  echo "    stop:       Stop a running container"
  echo "    restart:    Restart a container"
  echo "    destroy:    Stop and remove a container"
  echo "    enter:      Use nsenter to enter a container"
  echo "    build:      Build a new container "
  echo "    rebuild:    Rebuild a container (destroy old, bootstrap, start new)"
  echo "    cleanup:    Remove all containers that have stopped for > 24 hours"
  echo
  exit 1
}

# build the docker container
doBuild () {
	${DOCKER_PATH} build --tag ${IMAGE_NAME} .
}


# start the docker container
doStart () {
  check_ports ${EXPORT_PORT}

  existing=`${DOCKER_PATH} ps | awk '{ print $1, $(NF) }' | grep " $DOCKER_NAME$" | awk '{ print $1 }'`

  if [[ ! -z $existing ]]; then
     echo '${DOCKER_NAME} already running !'
  else	 
     ${DOCKER_PATH} run --name ${DOCKER_NAME} --publish ${EXPORT_PORT}:22 --volume ${VOLUME_MOUNT} ${IMAGE_NAME}
  fi

}

# start the docker container
doRestart () {
  doStop
  doStart
}

doEnter () {
  existing=`${DOCKER_PATH} ps | awk '{ print $1, $(NF) }' | grep " $DOCKER_NAME$" | awk '{ print $1 }'`

  if [[ ! -z $existing ]]; then
     exec ${DOCKER_PATH} exec -it ${DOCKER_NAME} /bin/bash
  else
    doStart
  fi
}

# stop the docker container
doStop () {
  existing=`${DOCKER_PATH} ps | awk '{ print $1, $(NF) }' | grep " $DOCKER_NAME$" | awk '{ print $1 }'`

  if [[ ! -z $existing ]]; then
	   ${DOCKER_PATH} stop -t 10 ${DOCKER_NAME}
  fi
}


# delete the docker container
doDestroy () {
  doStop
  $(docker rm ${DOCKER_NAME} && docker rmi ${IMAGE_NAME}) || (echo "${DOCKER_NAME} was not found" && exit 0)
  exit 0
}


doRebuild () {
  doDestroy
  doBuild
}

[ -z $DOCKER_PATH ] && {
   install_docker
}


# environment check 
launcher_start

# check the args number and print usage
[ $# -lt 1 ] && {
  usage
}

while getopts 'build:rebuild:enter:restart:stop:destroy:' OPT; do
	case $OPT in
        build)
    			doBuild
    			;;
        rebuild)
          doRebuild
          ;;
    		enter)
    			doEnter
    			;;
        restart)
          doRestart
          ;;
    		stop)
    			doStop
    			;;
        destroy)
          doDestroy
          ;;    	
    		\?)
    			doHelp
			   ;;
	esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.