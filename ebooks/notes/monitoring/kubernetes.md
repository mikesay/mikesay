## Monitoring Kubernetes

### What to monitor for Kubernetes?

+ 12 Critical Kubernetes Health Conditions You Need to Monitor and Why  
https://www.circonus.com/2020/12/12-critical-kubernetes-health-conditions-you-need-to-monitor-and-why/#:~:text=Disk%20pressure%20is%20a%20condition,set%20in%20your%20Kubernetes%20configuration.

### Collect container logs in Kubernetes
#### Container logs are output to stdout/stderr
This is the suggested way for containers to ouput the log. Deploy daemonset log agent, collect container logs from the log file in host file system:  

![monitoring](../_media/monitoring/k8s-log-1.png)

#### Collect log files inside container
##### Use daemonset log collectting agent
Below two methods are from https://github.com/kubernetes/kubernetes/issues/12567. The idea behind is to mount the log file to host filesystem by HostPath or EmptyDir, however both of them have disadvantages, and are not suggested:  

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

Below two methods are to redirect the content of log file in container to container's stdout/stderr, so to use the method "Container logs are output to stdout/stderr":  
+ Use a "streaming container" as sidecar containers to redirect log files to the stdout of each sidecar container  
    ![monitoring](../_media/monitoring/k8s-log-2.png)

    ```yaml
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
    name: test-log-collecting
    ---
    apiVersion: v1
    kind: Pod
    metadata:
    name: demo1
    namespace: test-log-collecting
    spec:
    containers:
        - name: demo1
        image: busybox
        imagePullPolicy: "Always"
        resources:
            limits:
            cpu: '100m'
            memory: '256Mi'
            requests:
            cpu: '50m'
            memory: '128Mi'
        args:
            - /bin/sh
            - -c
            - >
            i = 0;
            while true;
            do
                echo "$i: $(date)" >> /var/log/1.log;
                echo "$(date) INFO $i" >> /var/log/2.log;
                i=$((i+1));
                sleep 1;
            done
        volumeMounts:
            - name: varlog
            mountPath: /var/log
        - name: count-log-1
        image: busybox
        imagePullPolicy: "Always"
        resources:
            limits:
            cpu: '100m'
            memory: '256Mi'
            requests:
            cpu: '50m'
            memory: '128Mi'
        args:
            - /bin/sh
            - -c
            - tail -n+1 -f /var/log/1.log
        volumeMounts:
            - name: varlog
            mountPath: /var/log
        - name: count-log-2
        image: busybox
        imagePullPolicy: "Always"
        resources:
            limits:
            cpu: '100m'
            memory: '256Mi'
            requests:
            cpu: '50m'
            memory: '128Mi'
        args:
            - /bin/sh
            - -c
            - tail -n+1 -f /var/log/2.log
        volumeMounts:
            - name: varlog
            mountPath: /var/log
    volumes:
        - name: varlog
        emptyDir: {}
    restartPolicy: OnFailure
    ```
    > The sidecar container name can be set to the name of each log file, so that the final collected log can know which log file the log came from.  

+ symbol link log files to container's stdout, stderr like Nginx
    ```yaml
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
    name: test-log-collecting
    ---
    apiVersion: v1
    kind: Pod
    metadata:
    name: demo
    namespace: test-log-collecting
    spec:
    containers:
        - name: demo
        image: busybox
        imagePullPolicy: "Always"
        resources:
            limits:
            cpu: '200m'
            memory: '512Mi'
            requests:
            cpu: '100m'
            memory: '256Mi'
        args:
            - /bin/sh
            - -c
            - >
            mkdir -p /var/log;
            echo "hello 1.log" > /var/log/1.log;
            echo "hello 2.log" > /var/log/2.log;
            ln -sf /dev/stdout /var/log/1.log;
            ln -sf /dev/stdout /var/log/2.log;
            i = 0;
            while true;
            do
                echo "$i: $(date)" >> /var/log/1.log;
                echo "$(date) INFO $i" >> /var/log/2.log;
                i=$((i+1));
                sleep 1;
            done
    restartPolicy: OnFailure
    ```  
    >  This needs to update the dockerfile to add one step to do the symbol link. However, if there were multiple log files, from the final collected log, it can't tell which log file it came from.

##### Use sidecar log collecting agent
Inject log collecting agent as sidecar into pod, and mount and share the log folder using EmptyDir  
![monitoring](../_media/monitoring/k8s-log-3.png)  
