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

+ KeyCloak error - PKIX path building failed: SunCertPathBuilderException: unable to find valid certification path to requested target  
    Import the CA to java keystore, and use java keystore in KeyCloak command line.  

    ```bash
    kcadm.sh config credentials --truststore /jdk/lib/security/cacerts --server https://keycolak.minikube:1443 --realm master --user xxxx --password xxxx
    ```  

