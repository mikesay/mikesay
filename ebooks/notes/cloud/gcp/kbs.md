## GCP Knowledge base

### Generate kubeconfig file locally for GKE

+ gcloud to login to one google account
    ```bash
    gcloud auth login
    ```

    List credentialed accounts:  
    ```bash
    gcloud auth list
    ```

+ gcloud init/config to configure connection to GCP
    https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl?hl=en_US#using-gcloud-init

    **gcloud init**:  
    ```bash
    If you receive the error One of [--zone, --region] must be supplied: Please specify location, complete this section.

    Run gcloud init and follow the directions:


    gcloud init
    If you are using SSH on a remote server, use the --console-only flag to prevent the command from launching a browser:


    gcloud init --console-only
    Follow the instructions to authorize gcloud to use your Google Cloud account.
    Create a new configuration or select an existing one.
    Choose a Google Cloud project.
    Choose a default Compute Engine zone for zonal clusters or a region for regional or Autopilot clusters.
    ```

    **gcloud config**:  
    ```bash
    Set your default project ID:

    gcloud config set project PROJECT_ID
    If you are working with zonal clusters, set your default compute zone:

    gcloud config set compute/zone COMPUTE_ZONE
    If you are working with Autopilot or regional clusters, set your default compute region:

    gcloud config set compute/region COMPUTE_REGION
    Update gcloud to the latest version:

    gcloud components update
    ```

+ Get kube config file aid-collage-test specified in KUBECONFIG
    ```bash
    KUBECONFIG=aid-collage-test && gcloud container clusters get-credentials aid-collage-test
    ```

    List all configurations:  
    ```bash
    gcloud config configurations list
    ```

    Activate one configuration:  
    ```bash
    gcloud config configurations activate default
    ```

    List all configures in one configuration:  
    ```bash
    gcloud config list
    ```

    Create a new named configuration:  
    ```bash
    gcloud config configurations create test
    ```

+ Add new kube config file to the existing layout

+ Run kubectl command against the newly added kubernetes to generate access token into the kube config file automatically