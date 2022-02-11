## Gradle with Artifactory Support
### build.gradle
```groovy
plugins {
    id 'org.springframework.boot' version '2.4.1'
    id 'io.spring.dependency-management' version '1.0.10.RELEASE'
    id 'java'
    id 'maven-publish'
    id "com.jfrog.artifactory" version "4.18.2"
    id "com.dorongold.task-tree" version "1.5"
}

group = 'com.mikesay.notes'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '1.8'

// Repository here used to resolve project dependencies
repositories {
    maven {
        url "https://artifactory.mikesay.com/artifactory/mikesay-gradle-virtual"
        credentials {
            username = "${artifactory_user}" // Artifactory user name
            password = "${artifactory_password}" // Password or API Key
        }
    }
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    compileOnly 'org.projectlombok:lombok'
    developmentOnly 'org.springframework.boot:spring-boot-devtools'
    runtimeOnly 'org.postgresql:postgresql'
    annotationProcessor 'org.projectlombok:lombok'
    testImplementation('org.springframework.boot:spring-boot-starter-test') {
    exclude group: 'org.junit.vintage', module: 'junit-vintage-engine'
    }
    compile group: 'com.squareup.okhttp3', name: 'okhttp', version: '4.7.2'
}

test {
    useJUnitPlatform()
}

// Enable building the normal jar archive
jar {
    enabled = true
    classifier = 'normal'
}

// Eable building the source jar archive
task sourceJar(type: Jar) {
    from sourceSets.main.allSource
    archiveClassifier = "sources"
}

assemble.dependsOn sourceJar

// publishing task is from Maven publish plugin
// Define publications in this gradle project
// Use "artifact" to specify the task that generates jar file
publishing {
    publications {
        mavenJava(MavenPublication) {
            from components.java
            artifact sourceJar
            artifact bootJar
        }
    }
}

artifactory {
    contextUrl = 'https://artifactory.mikesay.com/artifactory/'
    publish {
        repository {
            repoKey = 'mikesay-gradle-virtual' // The Artifactory repository key to publish to
            username = "${artifactory_user}" // The publisher user name
            password = "${artifactory_password}" // The publisher password
            maven = true
        }
        defaults {
            // Reference to Gradle publications defined in the build script.
            // This is how we tell the Artifactory Plugin which artifacts should be
            // published to Artifactory.
            publications('mavenJava')
            publishBuildInfo = true
            publishArtifacts = true
            // Properties to be attached to the published artifacts.
            properties = ['qa.level': 'basic', 'dev.team' : 'core']
            publishPom = true // Publish generated POM files to Artifactory (true by default)
        }
    }
}
```


### settings.gradle
```groovy
pluginManagement {
    // Repository here used to resolve plugins
    repositories {
        maven {
            url 'https://artifactory.mikesay.com/artifactory/mikesay-gradle-virtual'
            credentials {
                username = "${artifactory_user}"
                password = "${artifactory_password}"
            }
        }
    }
}
rootProject.name = 'gradlesample'
```

## Gradle useful links

### Gradle publishing setup
https://docs.gradle.org/current/userguide/publishing_setup.html

### Maven publish plugin
https://docs.gradle.org/current/userguide/publishing_maven.html

### Artifactory gradle plugin
https://www.jfrog.com/confluence/display/JFROG/Gradle+Artifactory+Plugin#GradleArtifactoryPlugin-TheArtifactoryProjectPublishTask

### SpringFramework.Boot gradle plugin
https://docs.spring.io/spring-boot/docs/current/gradle-plugin/reference/htmlsingle/

### Search gradle plugin
https://plugins.gradle.org/