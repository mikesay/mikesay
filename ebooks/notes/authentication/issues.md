## Issues
+ PKIX path building failed: SunCertPathBuilderException: unable to find valid certification path to requested target  
    https://magicmonster.com/kb/prg/java/ssl/pkix_path_building_failed/ 

    Where is the keystore of Java?  
    ```bash
    ./jdk1.6.0_24/jre/lib/security/cacerts
    ./jre1.6.0_24/lib/security/cacerts
    ```  

    Dump its contents by using the list option:  
    ```bash
    keytool -list -v -keystore /path/to/cacerts  > java_cacerts.txt
    Enter keystore password:  changeit
    ```  

    Import PKI certificates:  
    ```bash
    keytool -import -alias example -keystore  /path/to/cacerts -file example.der
    ```  

+ KeyCloak CLI(kcadm.sh) error - PKIX path building failed: SunCertPathBuilderException: unable to find valid certification path to requested target  
    Firstly, import the CA to java keystore, and use java keystore in KeyCloak command line.  

    Secondly, set java keystore as the trust store for KeyCloak.  
    ```bash
    kcadm.sh configure truststore /usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home/lib/security/cacerts --trustpass xxxx
    ```

    Third, configure credentials of KeyCloak
    ```bash
    kcadm.sh config credentials --server https://keycolak.minikube:1443 --realm master --user xxxx --password xxxx
    ```  

    Finally, the generated configure file is at "~/.keycloak/kcadm.config":  
    ```json
    {
        "serverUrl" : "https://keycolak.minikube:1443",
        "realm" : "master",
        "truststore" : "/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home/lib/security/cacerts",
        "trustpass" : "xxxx",
        "endpoints" : {
                "https://keycolak.minikube:1443" : {
                "master" : {
                    "clientId" : "admin-cli",
                    "token" : "xxxx",
                    "refreshToken" : "xxxx",
                    "grantTypeForAuthentication" : "password",
                    "expiresAt" : 1714449549933,
                    "refreshExpiresAt" : 1714451289933
                }
            }
        }
    }
    ```  