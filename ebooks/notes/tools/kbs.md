# Useful tools & scripts

## Useful tools

| Tool                                                         | Description                                                                 |
| -------------------------------------------------------------| --------------------------------------------------------------------------- |
| https://jwt.io/                                              | JWT.IO allows you to decode, verify and generate JWT.                       |
| https://8gwifi.org/jwkconvertfunctions.jsp#google_vignette   | JWK to/from PEM Converter online.                                           |
| http://myip.ipip.net                                         | Check current IP. ```curl http://myip.ipip.net```                           |
| https://ipinfo.io                                            | Check IP information like location. ```curl https://ipinfo.io/$IP```        |

  
## Useful commands or scripts

| Command or Script                      | Description |
| --------------------------| ----------- |
| ```echo $PASSWD \| passwd --stdin $NEWUSR```      | Change login password.       |
| ```pwgen -c -n 10```   | Generate pronounceable passwords.        |
| ```journalctl -xefu kubelet,containerd,docker --since "2023-07-05 07:00:00" --until "2023-07-05 11:00:00"```  | Check kubernetes components' log from node.        |
| ```docker system prune -af```  | Clean docker images.        |
| ```crictl rmi --prune```  | Clear containerd images.        |
| ```ctr images pull docker.io/library/alpine:latest```  | Pull images using ctr command line.        |
| ```HOMEBREW_FORCE_BREWED_CURL=1 &&  brew install hashicorp/tap/vault```  | Use GNU curl in brew command, otherwize may met error "curl: (56) LibreSSL SSL_read: "<br/> SSL_ERROR_SYSCALL, errno 54 |
| ```find . -name "xxxx.yaml" -exec yq '(.dependencies[] \| select(.xxxx == "xxxx")).xxxx = "replaced value"' {} -i \;```  | Edit one filed of yaml files in place in batches. |
| ```jq '(..\|select(has("datasource"))?) += {datasource: "${datasource}"}' CS_Cost_Application.json```  | jq command searches all "datasource" key and replace their value. |
| ```curl --resolve accounts.google.com:443:64.233.189.84 https://accounts.google.com/.well-known/openid-configuration``` | Test url by ignoring DNS parsing. |