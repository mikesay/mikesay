## AliCloud Knowledge Base

### Create a non UI account and grant limit ACK permission

#### Create a RAM user with limit permission
+ Create a RAM user with only API access option

+ Grant RAM user read-only permission for AliCloud ACK cluster

+ Grant RAM user RBAC permission in ACK console

#### Get kubeconfig file by AliCloud CLI
+ Follow guide https://help.aliyun.com/document_detail/198808.html?spm=a2c4g.436762.0.0.e52f582eL2HedQ to install and configure AliCloud CLI "arc"

+ Follow guide https://help.aliyun.com/document_detail/436762.html?spm=a2c4g.198808.0.0.82d3fd37GeuNr6 to get kubeconfig content 
> The kubeconfig content is a string in the "config" field of json response, so need next steps to convert it to yaml

+ Install pyyaml module for python
```bash
pip install pyyaml
```

+ Create a python script i.e. str2yaml.py with below content and assign the string type of kubeconfig to variable "kubeconfig"  
    ```py
    import yaml

    kubeconfig = "xxxx"

    kubeconfig = yaml.safe_load(kubeconfig)

    with open('kubeconfig.yaml', 'w') as file:
        yaml.dump(kubeconfig, file)

    print(open('kubeconfig.yaml').read())
    ```

+ Run "str2yaml.py" to generate the kubeconfig.yaml
```bash
python str2yaml.py
```



