## Kubernetes issues
Awesome Kubernetes.

### Rapid Pod IP reuse
https://github.com/projectcalico/calico/issues/4152
https://github.com/projectcalico/calico/issues/3467


### KubeletHasDiskPressure
Need to check what are using the most of disk space.

```bash
df -h
du -h -d 1
ls -lhS
```

Sometimes it was cuased by the rotated kubelet log files:  
```bash
/var/log/message-*
```
so, rm them.