## 3 Steps to Install OpenJDK 11 on macOS

https://medium.com/@datatec.studio/3-steps-to-install-openjdk-11-on-macos-3ae0e10dfa1a

### Check
```bash
java -version
```

```bash
/usr/libexec/java_home -V
```

### Install
List availabe openjdk version:  
```bash
brew search openjdk  
```

```bash
export HOMEBREW_FORCE_BREWED_CURL=1
sudo rm -fr /Users/yourUserName/Library/Java/JavaVirtualMachines/*
sudo rm -fr /Library/Java/JavaVirtualMachines/*
brew install openjdk@17
```
Follow the instruction from the prompt after brew install:  

For the system Java wrappers to find this JDK, symlink it with
```bash
  sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
``` 

openjdk@17 is keg-only, which means it was not symlinked into /usr/local,  
because this is an alternate version of another formula.  

If you need to have openjdk@17 first in your PATH, run:  
```bash
  echo 'export PATH="/usr/local/opt/openjdk@17/bin:$PATH"' >> ~/.bash_profile
```  
> If this installed openjdk was the only one, this step can be skipped.  

For compilers to find openjdk@17 you may need to set:  
```bash
echo 'export CPPFLAGS="-I/usr/local/opt/openjdk@17/include"'  >> ~/.bash_profile
```

Add JAVA_HOME in case any java program needs it:  
```bash
echo 'export JAVA_HOME="/usr/local/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"' >> ~/.bash_profile
```

> ```export HOMEBREW_FORCE_BREWED_CURL=1``` enable brew command to use brew installed curl which is GNU curl.    
> If brew[Homebrew](https://brew.sh/) was not installed, run ```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"``` to install it firstly.  

#### Issues met

```
configure: error: XCode tool 'metal' neither found in path nor with xcrun
/private/tmp/openjdkA17-20230717-22770-1ftaff4/jdk17u-jdk-17.0.7-ga/build/.configure-support/generated-configure.sh: line 84: 5: Bad file descriptor
configure exiting with result code 1
```

Solve:  
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```
> Reference: https://github.com/gfx-rs/gfx/issues/2309



### Check
+ Java version
```bash
java -version
```
output:  
```text
openjdk version "11.0.19" 2023-04-18
OpenJDK Runtime Environment Homebrew (build 11.0.19+0)
OpenJDK 64-Bit Server VM Homebrew (build 11.0.19+0, mixed mode)
```

+ Java home
```bash
/usr/libexec/java_home -V
```
output:  
```text
Matching Java Virtual Machines (2):
    17.0.7, x86_64:	"OpenJDK 17.0.7"	/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
    11.0.19, x86_64:	"OpenJDK 11.0.19"	/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home

/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
```

+ Brew info of openjdk  
```bash
brew info openjdk
```

## Getting Started with Java in VS Code
https://code.visualstudio.com/docs/java/java-tutorial  

