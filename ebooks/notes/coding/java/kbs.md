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
```bash
sudo rm -fr /Users/yourUserName/Library/Java/JavaVirtualMachines/*
sudo rm -fr /Library/Java/JavaVirtualMachines/*
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install openjdk@11
sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk

```

+ Add bin folder of jdk in PATH
```bash
 echo 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"' >> /Users/mizha53/.bash_profile
```

+ For compilers to find openjdk you may need to set
```bash
echo 'export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/openjdk@11/include"' >> /Users/mizha53/.bash_profile
```

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
Matching Java Virtual Machines (1):
    11.0.19, x86_64:	"OpenJDK 11.0.19"	/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home

/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home
```

+ Brew info of openjdk
```bash
brew info openjdk
```

## Getting Started with Java in VS Code
https://code.visualstudio.com/docs/java/java-tutorial  

