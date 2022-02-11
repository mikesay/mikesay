## Materials 
### AlertManager
+ What’s the difference between group_interval, group_wait, and repeat_interval?

    https://www.robustperception.io/whats-the-difference-between-group_interval-group_wait-and-repeat_interval

    + group_wait  
    How long to wait to buffer alerts of the same group before sending a notification initially.

    + group_interval  
    How long to wait before sending an alert that has been added to a group for which there has already been a notification.

    
    + repeat_interval  
    How long to wait before re-sending a given alert that has already been sent in a notification.

+ Silence alert in the config file of AlertManager  
https://stackoverflow.com/questions/54806336/how-to-silence-prometheus-alertmanager-using-config-files

```bash
route:
  # Other settings...
  group_wait: 0s
  group_interval: 1m
  repeat_interval: 1h

  # Default receiver.
  receiver: "null"

  routes:
  # continue defaults to false, so the first match will end routing.
  - match:
      # This was previously named DeadMansSwitch
      alertname: Watchdog
    receiver: "null"
  - match:
      alertname: CPUThrottlingHigh
    receiver: "null"
  - receiver: "regular_alert_receiver"

receivers:
  - name: "null"
  - name: regular_alert_receiver
    <snip>
```

### Prometheus

+ What's the difference between scrape_interval and evaluation_interval?

    + scrape_interval  
    The time between each Prometheus scrape (i.e when Prometheus is pulling data from exporters etc.).
    
    + evaluation_interval  T
    he time between each evaluation of Prometheus' alerting rules.



## Kubernetes Monitoring and Metrics
  
### Official materials
+ General  
https://github.com/kubernetes/metrics

+ Implementation  
https://github.com/kubernetes/metrics/blob/master/IMPLEMENTATIONS.md  

+ Prometheus Adapter  
https://github.com/kubernetes-sigs/prometheus-adapter  

+ Base library used by Adapter:  
https://github.com/kubernetes-sigs/custom-metrics-apiserver  

### Other materials
+ Kubernetes Metrics  
https://help.sumologic.com/Metrics/Kubernetes_Metrics

+ Introduction to Kubernetes Monitoring Architecture  
https://medium.com/kubernetes-tutorials/introduction-to-kubernetes-monitoring-architecture-98a265e0917d  

Kubelet CAdvisor:  
![kubelet-cadvisor](../_media/k8s/kubelet-cadvisor.png)  

Core monitoring pipeline:  
![core-monitoring-pipeline](../_media/k8s/core-monitoring-pipeline.jpeg)  

+ Logging and Monitoring Kubernetes
https://www.sumologic.com/blog/kubernetes-logs/  

+ Monitoring Kubernetes: The K8s Anatomy (Crash Course, Part 1)
https://www.sumologic.com/blog/monitoring-kubernetes-anatomy/  

+ Monitoring Kubernetes: What to Monitor (Crash Course, Part 2)
https://www.sumologic.com/blog/kubernetes-monitoring/  

+ Service discovery for ECS
https://github.com/seanly/prometheus-ecs-sd  

+ Effectively Managing Kubernetes Resources with Cost Monitoring
https://medium.com/kubecost/effectively-managing-kubernetes-with-cost-monitoring-96b54464e419  


## Prometheus Stack
### Doc and Code
https://prometheus.io/docs/introduction/overview/
https://github.com/prometheus

### Prometheus Helm Chart
https://artifacthub.io/packages/helm/prometheus-community/prometheus  
https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus  

### AlertManager Helm Chart
https://artifacthub.io/packages/helm/prometheus-community/alertmanager  
https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager  

### Prometheus Operator
https://prometheus-operator.dev/  
https://github.com/prometheus-operator/prometheus-operator  

#### Limit of Promethues Operator
+ Do not support HA. Promethues Operator was developed earlier than operator-sdk, so it didn't enjoy the out-of-box HA ability of operator-sdk. It needs to use the LeaderElection mechanism of client-go explicitly, which has already been integrated by operator-sdk.

### kube-prometheus
https://github.com/prometheus-operator/kube-prometheus  

This repository collects Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator.  

### Prometheus Monitoring Community
https://prometheus.io/community/
https://github.com/prometheus-community

## Grafana Stack
### Doc and Code
https://grafana.com/docs/grafana/latest/
https://github.com/grafana/grafana

### Grafana Helm Chart
https://github.com/grafana/helm-charts  
https://github.com/grafana/helm-charts/tree/main/charts/grafana

### Grafana Operator
https://operatorhub.io/operator/grafana-operator  
https://github.com/grafana-operator/grafana-operator
