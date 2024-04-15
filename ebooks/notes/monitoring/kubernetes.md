## Monitoring Kubernetes

### What to monitor for Kubernetes?

+ 12 Critical Kubernetes Health Conditions You Need to Monitor and Why  
https://www.circonus.com/2020/12/12-critical-kubernetes-health-conditions-you-need-to-monitor-and-why/#:~:text=Disk%20pressure%20is%20a%20condition,set%20in%20your%20Kubernetes%20configuration.

### Collect logs
#### Collect log files inside container

##### Use daemonset log collectting agent
https://github.com/kubernetes/kubernetes/issues/12567  
+ HostPath Volume  
    Mount the logdir(/log) by HostPath Volume, like:  
    ```bash
    /var/log/pods/<pod_name> => /log
    ```  
    Use /var/log/pods/<pod_name> to persist the logs, it's configured manually, so fluentd can distinguish the logs file also. But all the pod's instances will use the same HostPath(/var/log/pods/<pod_name>), this can cause conflict.  

+ EmptyDir Volume  
    Mount the logdir(/log) by EmptyDIr Volume, like:  
    ```bash
    /var/lib/kubelet/pods/<pod_id>/volumes/kubernetes.io~empty-dir/log-storage => /log
    ```  
    fluentd can tail the logfiles in /var/lib/kubelet/pods/<pod_id>/volumes/kubernetes.io~empty-dir/log-storage, but the path only include pod_id, pod_id changes when pod migrates, so I don't think it's ok to be the tag.  

+ symbol link log files to container's stdout, stderr like Nginx
    This needs to update the dockerfile to add one step to do the symbol link.This is could be the better one which will follow the standard collecting method, so that both pod name and container name can be collected into logs.  

##### Use sidecar log collecting agent
Inject log collecting agent as sidecar into pod, and mount and share the log folder using EmptyDir  
