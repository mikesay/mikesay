## Build order of Maven modules
If two modules's dependency is not specified apparently, the build order will depends on the order of these two modules in pom file.

## Maven property overwrite strategy
+ Properties with equal names are overridden in next sequence (from highest to lowest context):
    + Global
        Defined in the global Maven-settings (%M2_HOME%/conf/settings.xml).
    + Profile descriptor
        A descriptor located in project basedir (profiles.xml) (unsupported in Maven 3.0: see Maven 3 compatibility notes)
    + Per project
        Defined in the POM itself (pom.xml).
    + Per user
        Defined in the Maven-settings (%USER_HOME%/.m2/settings.xml).

    Hence, pom.xml properties (per project) are overridden by settings.xml (per user) properties with equal names.

+ The properties passed by -D option will be the highes preference.

## Maven deploy artifact manually

**Deploy a single artifact with a generic pom (generated automatically)**
```sh
mvn deploy:deploy-file -DgroupId=com.mikesay.test -DartifactId=helloworld -Dversion=1.0.0 -Dpackaging=jar -Dfile=helloworld-1.0.0.jar -DrepositoryId=helloworld -Durl=https://xxxx/artifactory/mvn-local
```
> If don't want to generate a generic pom, add option "-DgeneratePom=false"

**Deploy a single artifact with a customised pom**
```sh
mvn deploy:deploy-file -DgroupId=com.mikesay.test -DpomFile=pom.xml -Dfile=helloworld-1.0.0.jar -DrepositoryId=helloworld -Durl=https://xxxx/artifactory/mvn-local
```

## Maven disalbe SSL check

Add following command property.
```sh
-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true
```
You can disable SSL certificate checking by adding one or more of these command line parameters:  
-Dmaven.wagon.http.ssl.insecure=true - enable use of relaxed SSL check for user generated certificates.  
-Dmaven.wagon.http.ssl.allowall=true - enable match of the server's X.509 certificate with hostname. If disabled, a browser like check will be used.  
-Dmaven.wagon.http.ssl.ignore.validity.dates=true - ignore issues with certificate dates.

> Reference:  
  https://stackoverflow.com/questions/21252800/how-to-tell-maven-to-disregard-ssl-errors-and-trusting-all-certs  
  http://maven.apache.org/wagon/wagon-providers/wagon-http/