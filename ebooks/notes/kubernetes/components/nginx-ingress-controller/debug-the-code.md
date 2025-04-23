# Debugging Nginx Ingress Controller and Validation Admission Webhook (VS Code Configuration Guide)
This guide provides step-by-step instructions for debugging the Nginx Ingress Controller and its Validation Admission Webhook using VS Code.  

## Prerequisites
+ VS Code installed with the Go extension configured  
+ Access to a Kubernetes cluster (via kubectl configuration)  
+ Basic familiarity with Docker commands  


## Step-by-Step Guide
1. Clone the Repository 
    ```bash
    git clone https://github.com/kubernetes/ingress-nginx.git
    cd ingress-nginx
    ```  

2. Apply Debug Patch
    ```bash
    git apply local-debug-pack.diff
    ```  

    > This patch will adjuest some code and configurations to enable local debugging for the controller and webhook.  


3. Create Temporary Directories  
    ```bash
    mkdir -p rootfs/etc/ingress-controller
    mkdir -p rootfs/webhookcertificates
    ```  

    > These directories store temporary files and certificates required for debugging.  

4. Copy SSL Certificates  
    Run below commands to retrieve the self-signed certificate from an existing Nginx Ingress Controller Pod:  
    ```bash
    kubectl cp -c nginx-ingress-controller "kube-system/nginx-ingress-controller-xxxx:$(kubectl -n kube-system exec -c nginx-ingress-controller nginx-ingress-controller-xxxx -- readlink -f /usr/local/certificates/cert)" ./rootfs/webhookcertificates/cert  2>&1 > /dev/null

    kubectl cp -c nginx-ingress-controller "kube-system/nginx-ingress-controller-xxxx:$(kubectl -n kube-system exec -c nginx-ingress-controller nginx-ingress-controller-xxxx -- readlink -f /usr/local/certificates/key)" ./rootfs/webhookcertificates/key  2>&1 > /dev/null
    ```  

    > Alternative: Generate certificates using OpenSSL if needed.

5. Open the cloned repository in VS Code  

6. Copy or create the launch.json file:  
    + Create a .vscode folder in the project root if it doesn't exist.  
    + Add a launch.json file inside the .vscode folder.  
        // Example `launch.json` configuration for debugging the Nginx Ingress Controller and Webhook:  
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

        > 
        Adjustments required:
        + Update --kubeconfig to point to your Kubernetes config file.  
        + Ensure --webhook-port and --metrics-bind-address match your setup.  
        + Verify certificate paths (webhook-cert-file, webhook-key-file) match the rootfs/ directories you created earlier.  

## Debugging the Validation Admission Webhook
1. Set Breakpoints  
    + Webhook Entry Point: Set breakpoints in internal/admission/controller/main.go.  
    + Controller Entry Point: Set breakpoints in cmd/nginx/main.go for the main controller logic.  

2. Start Debugging  
    + Launch the controller via the VS Code Debug Panel.  
    + Wait for the controller to start and listen on the specified ports.  

3. Test the Webhook  
    Send a test request to trigger the webhook from root folder:  
    ```bash
    curl -d @test/adminssion-review-request.json -k -v -X POST https://localhost:8888/networking/v1/ingresse
    ```  

    > 
    Note: The -k flag skips SSL certificate verification.  
    The payload format is the resource kind "AdmissionReview" (https://kubernetes.io/docs/reference/config-api/apiserver-admission.v1/).  


By following these steps, you can debug both the Nginx Ingress Controller and its Webhook simultaneously. Verify outputs at each step to ensure proper configuration.
Let me know if you need further refinements!