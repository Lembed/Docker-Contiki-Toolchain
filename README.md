# Docker-ContikiOsDev
A docker of contiki os development environment


``` bash
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
```

* Note: The dockerfile is base on
> https://raw.githubusercontent.com/Lembed/Contiki/master/.travis.yml

## Note
This development environment download and install all the compiler tools to build most of the platform and cpu, include 

1. msp430 gcc toolchain 
2. gcc for avr
3. gcc for arm
4. gcc for x86(32bit)
5. SDCC
6. CC65
7. rl78 gcc toolchain
8. nxp special toolchain
9. etc

At last it will git clone [contiki os](https://github.com/Lembed/Contiki-Cortex) sourc code to compile

for more detail please see Dockerfile

[![Analytics](https://ga-beacon.appspot.com/UA-67438080-1/Docker-Contiki-Toolchain/readme?pixel)](https://github.com/Lembed/Docker-Contiki-Toolchain)

