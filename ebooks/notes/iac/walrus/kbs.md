## Walrus knowledge base
TBD

### Installation and usage issue

If "cost management" was enabled during creating "Kubernetes" connector, a standalone prometheus server "walrus-prometheus-server" and two exporters "walrus-prometheus-prometheus-node-exporter", "walrus-prometheus-kube-state-metrics" will be deployed by walrus server, but two issues will be met:  

+ The walrus node exporter will be conflict on host port (9100) with existing node exporters which may come from ARMS prometheus of Alibaba Cloud, or other existing node exporters
    1 node(s) didn't have free ports for the requested pod ports  

+ The deployment of prometheus related components was launched by walrus server, so the default images are from docker hub, and it will be easy to hit rate limitting of docker hub  
    429 Too Many Requests - Server message: toomanyrequests: You have reached your pull rate limit.  

    > During installing walrus, the walrus server will also launch the deployment walrus workflow component, so it will also met the rate limitting issue of docker hub.  


+ tf-job-apply pod's DNS server uses non coredns  
    The DNS policy of pod is "ClusterFirst" while the network is "HostNetwork" which caused the DNS policy of pod fallback to the "Default" policy(https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy)  

    > Has been fixed in latest version

+ No upgrading support  

+ No support for private deployment like using private docker registry which needs docker pull secres

### Doc
+ Seal Launches Walrus 0.5: Revamps Workflow for an Out-of-the-Box Deployment Experience  
https://www.seal.io/resource/blog/walrus-05-release  


