# AliCloud Knowledge Base

## Create a non UI account and grant limit ACK permission

### Create a RAM user with limit permission
+ Create a RAM user with only API access option

+ Grant RAM user read-only permission for AliCloud ACK cluster

+ Grant RAM user RBAC permission in ACK console

### Get kubeconfig file by AliCloud CLI
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

## Development

### STS
阿里云STS（Security Token Service）是阿里云提供的一种临时访问权限管理服务。RAM提供RAM用户和RAM角色两种身份。其中，RAM角色不具备永久身份凭证，而只能通过STS获取可以自定义时效和访问权限的临时身份凭证，即安全令牌（STS Token）。  

> https://help.aliyun.com/zh/ram/product-overview/what-is-sts?spm=a2c4g.11186623.0.0.61462516ySd0YE  

### GO SDK
#### 管理访问凭证  
> https://help.aliyun.com/zh/sdk/developer-reference/v2-manage-go-access-credentials?spm=a2c4g.11186623.help-menu-262060.d_1_9_1_2.51ff2516yh24kA&scm=20140722.H_2579531._.OR_help-T_cn~zh-V_1  

凭据是指用户证明其身份的一组信息。用户在系统中进行登录时，需要提供正确的凭据才能验证身份。常见的凭据类型有:  
+ 阿里云主账号和RAM用户的永久凭据 AccessKey（简称AK）是由AccessKey ID和AccessKey Secret组成的密钥对。  
+ 阿里云RAM角色的STS临时访问Token，简称STS Token。它是可以自定义时效和访问权限的临时身份凭据，详情请参见什么是STS。  
+ Bearer Token。它是一种身份验证和授权的令牌类型。  

#### Use CMS SDK with credentials-go

```go
// This file is auto-generated, don't edit it. Thanks.
package main

import (
  "encoding/json"
  "strings"
  "fmt"
  "os"
  cms20190101  "github.com/alibabacloud-go/cms-20190101/v10/client"
  openapi  "github.com/alibabacloud-go/darabonba-openapi/v2/client"
  util  "github.com/alibabacloud-go/tea-utils/v2/service"
  credential  "github.com/aliyun/credentials-go/credentials"
  "github.com/alibabacloud-go/tea/tea"
)


// Description:
// 
// 使用凭据初始化账号 Client
// 
// @return Client
// 
// @throws Exception
func CreateClient () (_result *cms20190101.Client, _err error) {
  // 工程代码建议使用更安全的无 AK 方式，凭据配置方式请参见：https://help.aliyun.com/document_detail/378661.html。
  credential, _err := credential.NewCredential(nil)
  if _err != nil {
    return _result, _err
  }

  config := &openapi.Config{
    Credential: credential,
  }
  // Endpoint 请参考 https://api.aliyun.com/product/Cms
  config.Endpoint = tea.String("metrics.cn-hangzhou.aliyuncs.com")
  _result = &cms20190101.Client{}
  _result, _err = cms20190101.NewClient(config)
  return _result, _err
}

func _main (args []*string) (_err error) {
  client, _err := CreateClient()
  if _err != nil {
    return _err
  }

  deleteEventRulesRequest := &cms20190101.DeleteEventRulesRequest{}
  tryErr := func()(_e error) {
    defer func() {
      if r := tea.Recover(recover()); r != nil {
        _e = r
      }
    }()
    // 复制代码运行请自行打印 API 的返回值
    _, _err = client.DeleteEventRulesWithOptions(deleteEventRulesRequest, &util.RuntimeOptions{})
    if _err != nil {
      return _err
    }

    return nil
  }()

  if tryErr != nil {
    var error = &tea.SDKError{}
    if _t, ok := tryErr.(*tea.SDKError); ok {
      error = _t
    } else {
      error.Message = tea.String(tryErr.Error())
    }
    // 此处仅做打印展示，请谨慎对待异常处理，在工程项目中切勿直接忽略异常。
    // 错误 message
    fmt.Println(tea.StringValue(error.Message))
    // 诊断地址
    var data interface{}
    d := json.NewDecoder(strings.NewReader(tea.StringValue(error.Data)))
    d.Decode(&data)
    if m, ok := data.(map[string]interface{}); ok {
      recommend, _ := m["Recommend"]
      fmt.Println(recommend)
    }
    _, _err = util.AssertAsString(error.Message)
    if _err != nil {
      return _err
    }
  }
  return _err
}


func main() {
  err := _main(tea.StringSlice(os.Args[1:]))
  if err != nil {
    panic(err)
  }
}
```  
> https://api.aliyun.com/api-tools/sdk/Cms?version=2019-01-01&language=go-tea&tab=primer-doc  



