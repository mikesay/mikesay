# Debugging Nginx Ingress Controller and Validation Admission Webhook (VS Code Configuration Guide)  
This guide provides step-by-step instructions for debugging the Nginx Ingress Controller and its Validation Admission Webhook using VS Code.  

## Prerequisites  
- VS Code installed with the Go extension configured  
- Access to a Kubernetes cluster (configured via `kubectl`)  
- Basic familiarity with Docker commands  

## Step-by-Step Guide  

### 1. Clone the Repository  
```bash  
git clone https://github.com/kubernetes/ingress-nginx.git  
cd ingress-nginx  
```  

### 2. Apply Debug Patch
```bash
git apply local-debug-pack.diff  
```  
> **Note**: This patch adjusts code and configurations to enable local debugging for the controller and webhook.  

### 3. Create Temporary Directories
```bash
mkdir -p rootfs/etc/ingress-controller  
mkdir -p rootfs/webhookcertificates  
```  
> **Note**: These directories store temporary files and certificates required for debugging.

### 4. Copy SSL Certificates
Execute the following commands to retrieve self-signed certificates from an existing Nginx Ingress Controller Pod:  

```bash
kubectl cp -c nginx-ingress-controller "kube-system/nginx-ingress-controller-xxxx:$(kubectl -n kube-system exec -c nginx-ingress-controller nginx-ingress-controller-xxxx -- readlink -f /usr/local/certificates/cert)" ./rootfs/webhookcertificates/cert 2>&1 > /dev/null  

kubectl cp -c nginx-ingress-controller "kube-system/nginx-ingress-controller-xxxx:$(kubectl -n kube-system exec -c nginx-ingress-controller nginx-ingress-controller-xxxx -- readlink -f /usr/local/certificates/key)" ./rootfs/webhookcertificates/key 2>&1 > /dev/null  
```  

> **Alternative**: Generate certificates using OpenSSL if needed.  

### 5. Open the Cloned Repository in VS Code
### 6. Configure launch.json
•  Create a .vscode folder in the project root if it doesn't exist.  
•  Add the following launch.json configuration:  

    ```json
    {  
    "version": "0.2.0",  
    "configurations": [  
        {  
        "name": "Debug Nginx Ingress Controller",  
        "type": "go",  
        "request": "launch",  
        "mode": "auto",  
        "program": "${fileDirname}",  
        "env": {  
            "POD_NAME": "nginx-ingress-controller-xxxx",  
            "POD_NAMESPACE": "kube-system"  
        },  
        "args": [  
            "--kubeconfig=/path/to/your/kubeconfig",  
            "--http-port=8868",  
            "--https-port=8869",  
            "--ingress-class=nginx",  
            "--watch-ingress-without-class",  
            "--controller-class=k8s.io/ingress-nginx",  
            "--configmap=kube-system/nginx-configuration",  
            "--tcp-services-configmap=kube-system/tcp-services",  
            "--udp-services-configmap=kube-system/udp-services",  
            "--annotations-prefix=nginx.ingress.kubernetes.io",  
            "--enable-annotation-validation",  
            "--shutdown-grace-period=30",  
            "--validating-webhook=0.0.0.0:8888",  
            "--validating-webhook-certificate=../../rootfs/webhookcertificates/cert",  
            "--validating-webhook-key=../../rootfs/webhookcertificates/key",  
            "--v=2"  
        ],  
        "dlvLoadConfig": {  
            "followPointers": true,  
            "maxVariableRecurse": 1,  
            "maxStringLen": 800,  
            "maxArrayValues": 64,  
            "maxStructFields": -1  
        }  
        }  
    ]  
    }  
    ```  

> **Adjustments Required**:  
    •  Update --kubeconfig to point to your Kubernetes config file.  
    •  Ensure ports like --validating-webhook and --https-port match your setup.  
    •  Verify certificate paths (e.g., validating-webhook-certificate) match the rootfs/ directories.  

## Debugging the Validation Admission Webhook
### 1. Set Breakpoints
•  Webhook Entry Point: Set breakpoints in internal/admission/controller/main.go.  
•  Controller Entry Point: Set breakpoints in cmd/nginx/main.go for controller logic.  

### 2. Start Debugging
•  Launch the controller via the VS Code Debug Panel.  
•  Wait for the controller to start and listen on the specified ports.  

### 3. Test the Webhook
Send a test request to trigger the webhook from the root folder:  
```bash
curl -d @test/admission-review-request.json -k -v -X POST https://localhost:8888/networking/v1/ingresses  
```  

> **Note**:  
    •  The -k flag skips SSL certificate verification.  
    •  The payload format is AdmissionReview (see [Kubernetes Documentation](https://kubernetes.io/docs/reference/config-api/apiserver-admission.v1/)).  
    By following these steps, you can debug both the Nginx Ingress Controller and its Webhook simultaneously. Verify outputs at each step to ensure proper configuration.  

## Content of files mentioned in this doc
### launch.json  
```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Nginx Ingress Controller",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "program": "${fileDirname}",
            "env": {
                "POD_NAME": "nginx-ingress-controller-xxxx",
                "POD_NAMESPACE": "kube-system"
            },
            "args": [
                "--kubeconfig=/path/to/your/kubeconfig",
                "--http-port=8868",
                "--https-port=8869",
                "--ingress-class=nginx",
                "--watch-ingress-without-class",
                "--controller-class=k8s.io/ingress-nginx",
                "--configmap=kube-system/nginx-configuration",
                "--tcp-services-configmap=kube-system/tcp-services",
                "--udp-services-configmap=kube-system/udp-services",
                "--annotations-prefix=nginx.ingress.kubernetes.io",
                "--enable-annotation-validation",
                "--shutdown-grace-period=30",
                "--validating-webhook=0.0.0.0:8888",
                "--validating-webhook-certificate=../../rootfs/webhookcertificates/cert",
                "--validating-webhook-key=../../rootfs/webhookcertificates/key",
                "--v=2"
            ],
            "dlvLoadConfig": {
                "followPointers": true,
                "maxVariableRecurse": 1,
                "maxStringLen": 800,
                "maxArrayValues": 64,
                "maxStructFields": -1
            }
        }
    ]
}
```  

### git diff file

```yaml  
diff --git a/internal/ingress/controller/nginx.go b/internal/ingress/controller/nginx.go
index 20fad5afb..24bda9465 100644
--- a/internal/ingress/controller/nginx.go
+++ b/internal/ingress/controller/nginx.go
@@ -184,10 +184,10 @@ func NewNGINXController(config *Configuration, mc metric.Collector) *NGINXContro
 
 	filesToWatch := []string{}
 
-	if err := os.Mkdir("/etc/ingress-controller/geoip/", 0o755); err != nil && !os.IsExist(err) {
+	if err := os.Mkdir("../../rootfs/etc/ingress-controller/geoip/", 0o755); err != nil && !os.IsExist(err) {
 		klog.Fatalf("Error creating geoip dir: %v", err)
 	}
-	err = filepath.WalkDir("/etc/ingress-controller/geoip/", func(path string, info fs.DirEntry, err error) error {
+	err = filepath.WalkDir("../../rootfs/etc/ingress-controller/geoip/", func(path string, info fs.DirEntry, err error) error {
 		if err != nil {
 			return err
 		}
diff --git a/internal/ingress/controller/util.go b/internal/ingress/controller/util.go
index 975fb822a..5467941fd 100644
--- a/internal/ingress/controller/util.go
+++ b/internal/ingress/controller/util.go
@@ -98,9 +98,9 @@ func rlimitMaxNumFiles() int {
 }
 
 const (
-	defBinary  = "/usr/bin/nginx"
-	cfgPath    = "/etc/nginx/nginx.conf"
-	luaCfgPath = "/etc/nginx/lua/cfg.json"
+	defBinary  = "/opt/homebrew/bin/nginx"
+	cfgPath    = "../../rootfs/etc/nginx/nginx.conf"
+	luaCfgPath = "../../rootfs/etc/nginx/lua/cfg.json"
 )
 
 // NginxExecTester defines the interface to execute
diff --git a/internal/ingress/metric/collectors/process.go b/internal/ingress/metric/collectors/process.go
index 85e8066b5..b3c394592 100644
--- a/internal/ingress/metric/collectors/process.go
+++ b/internal/ingress/metric/collectors/process.go
@@ -98,7 +98,7 @@ type NGINXProcessCollector interface {
 
 var (
 	name   = "nginx"
-	binary = "/usr/bin/nginx"
+	binary = "/opt/homebrew/bin/nginx"
 )
 
 // NewNGINXProcess returns a new prometheus collector for the nginx process
diff --git a/internal/nginx/main.go b/internal/nginx/main.go
index fc586e9e8..afd3da024 100644
--- a/internal/nginx/main.go
+++ b/internal/nginx/main.go
@@ -40,10 +40,10 @@ var ProfilerPort = 10245
 var ProfilerAddress = "127.0.0.1"
 
 // TemplatePath path of the NGINX template
-var TemplatePath = "/etc/nginx/template/nginx.tmpl"
+var TemplatePath = "../../rootfs/etc/nginx/template/nginx.tmpl"
 
 // PID defines the location of the pid file used by NGINX
-var PID = "/tmp/nginx/nginx.pid"
+var PID = "../../rootfs/tmp/nginx/nginx.pid"
 
 // StatusPort port used by NGINX for the status server
 var StatusPort = 10246
diff --git a/pkg/util/file/structure.go b/pkg/util/file/structure.go
index 7d4f26da9..272d3649c 100644
--- a/pkg/util/file/structure.go
+++ b/pkg/util/file/structure.go
@@ -24,13 +24,13 @@ import (
 const (
 	// AuthDirectory default directory used to store files
 	// to authenticate request
-	AuthDirectory = "/etc/ingress-controller/auth"
+	AuthDirectory = "../../rootfs/etc/ingress-controller/auth"
 
 	// DefaultSSLDirectory defines the location where the SSL certificates will be generated
 	// This directory contains all the SSL certificates that are specified in Ingress rules.
 	// The name of each file is <namespace>-<secret name>.pem. The content is the concatenated
 	// certificate and key.
-	DefaultSSLDirectory = "/etc/ingress-controller/ssl"
+	DefaultSSLDirectory = "../../rootfs/etc/ingress-controller/ssl"
 )
 
 var directories = []string{
diff --git a/test/adminssion-review-request.json b/test/adminssion-review-request.json
new file mode 100644
index 000000000..ba76ddd31
--- /dev/null
+++ b/test/adminssion-review-request.json
@@ -0,0 +1,62 @@
+{
+    "kind": "AdmissionReview",
+    "apiVersion": "admission.k8s.io/v1",
+    "request": {
+        "uid": "800ab934-1343-01e8-b8cd-45010b400002",
+        "kind": {
+            "version": "v1",
+            "kind": "Ingress",
+            "group": "networking.k8s.io"
+        },
+        "resource": {
+            "version": "v1",
+            "resource": "ingresses",
+            "group": "networking.k8s.io"
+        },
+        "name": "test-api",
+        "namespace": "kong",
+        "operation": "CREATE",
+        "object": {
+            "apiVersion": "networking.k8s.io/v1",
+            "kind": "Ingress",
+            "metadata": {
+                "annotations": {
+                    "kubernetes.io/ingress.class": "kong"
+                },
+                "name": "test-api",
+                "namespace": "kong"
+            },
+            "spec": {
+                "ingressClassName": "kong",
+                "rules": [
+                    {
+                        "host": "test-api.mikesay.com",
+                        "http": {
+                            "paths": [
+                                {
+                                    "backend": {
+                                        "service": {
+                                            "name": "test-svc",
+                                            "port": {
+                                                "number": 80
+                                            }
+                                        }
+                                    },
+                                    "pathType": "ImplementationSpecific"
+                                }
+                            ]
+                        }
+                    }
+                ],
+                "tls": [
+                    {
+                        "hosts": [
+                            "*.mikesay.com"
+                        ],
+                        "secretName": "tls-mikesay-com"
+                    }
+                ]
+            }
+        }
+    }
+}
\ No newline at end of file
diff --git a/test/test-ingress.yaml b/test/test-ingress.yaml
new file mode 100644
index 000000000..07fb998aa
--- /dev/null
+++ b/test/test-ingress.yaml
@@ -0,0 +1,23 @@
+apiVersion: networking.k8s.io/v1
+kind: Ingress
+metadata:
+  annotations:
+    kubernetes.io/ingress.class: kong
+  name: test-api
+  namespace: kong
+spec:
+  ingressClassName: "kong"
+  rules:
+    - host: test-api.mikesay.com
+      http:
+        paths:
+          - backend:
+              service:
+                name: test-svc
+                port:
+                  number: 80
+            pathType: ImplementationSpecific
+  tls:
+    - hosts:
+        - '*.mikesay.com'
+      secretName: tls-mikesay-com
\ No newline at end of file
```  