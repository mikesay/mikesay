# Podman
https://podman.io/  
https://podman-desktop.io/  

## Setup

+ Download and install podman  
https://github.com/containers/podman/releases/tag/v4.9.3  

> The latest version v5 of podman is not compatible with Mac OS Monterey(12.7.3), so get the last v4.  

+ Download and install podman desktop  
https://github.com/containers/podman-desktop/releases  

+ Create podman machine using podman command line  

    ```bash
    podman --ssh native machine init --cpus 2 --disk-size 100 -m 4096 --now --rootful  --username mike podman-machine-default --log-level DEBUG
    ```  

    The configure file of podman machine and podman engine is at ~/.config/containers/containers.conf:  

    ```ini
    [containers]

    [engine]
    active_service = "podman-machine-default-root"
    [engine.service_destinations]
        [engine.service_destinations.podman-machine-default]
        uri = "ssh://mike@127.0.0.1:58813/run/user/501/podman/podman.sock"
        identity = "/Users/mike/.ssh/podman-machine-default"
        is_machine = true
        [engine.service_destinations.podman-machine-default-root]
        uri = "ssh://root@127.0.0.1:58813/run/podman/podman.sock"
        identity = "/Users/mike/.ssh/podman-machine-default"
        is_machine = true

    [machine]

    [network]

    [secrets]

    [configmaps]

    [farms]
    ```





