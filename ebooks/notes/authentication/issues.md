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

+ Java program error - sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target  
    Firstly, get the SSL certificate from website.  

    Secondly, import this SSL certificate.  
    ```bash
    keytool -import -alias keycloak -keystore $JAVA_HOME/lib/security/cacerts -file tls.crt
    ```  

+ Java program error - accessible: module java.base does not "opens java.util"  
    module system changes introduced in Java 9 and later versions. It occurs when you try to access a field, method, or class that is not accessible due to module restrictions. Read more:  https://www.java67.com/2023/09/how-to-fix-java-module-error-caused-by.html#ixzz8Z33FAIrg  

    Workaround is to use reflection with --add-opens Flag (Temporary Solution). In vscode, add vmArgs in "launch.json":  
    ```json
    {
        // Use IntelliSense to learn about possible attributes.
        // Hover to view descriptions of existing attributes.
        // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
        "version": "0.2.0",
        "configurations": [
            {
                "type": "java",
                "name": "Current File",
                "request": "launch",
                "mainClass": "${file}",
                "vmArgs": "--add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED --add-opens=java.base/jdk.internal.misc=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED --add-opens=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED --add-opens=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED  --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.time=ALL-UNNAMED --add-opens=java.base/java.time.format=ALL-UNNAMED"
            }
        ]
    }
    ```
