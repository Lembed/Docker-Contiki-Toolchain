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

