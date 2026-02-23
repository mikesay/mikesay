# Quick start setup MacOS

## Install openjdk

### Install latest openjdk  
```bash
brew install openjdk
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
echo 'export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"' >> /Users/mike/.bash_profile
echo 'export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"' >> /Users/mike/.bash_profile
```  

### Install multiple version of openjdk and manage the version using jenv
+ Install jenv  
    ```bash
    brew install jenv
    ```  
    > https://github.com/jenv/jenv  

+ Install export plugin to support setting JAVA_HOME dynamically  
    ```bash
    eval "$(jenv init -)"
    jenv enable-plugin export
    ```  

+ Add below configuration to ~/.bash_profile  
    ```bash
    # jenv
    eval "$(jenv init -)"

    # Re-export CPPFLAGS *after* JAVA_HOME is guaranteed set
    jenv_post_global() {
    if [[ -n "$JAVA_HOME" ]] &&[[ -d "$JAVA_HOME/include" ]]; then
        local os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
        local include_os="darwin"
        [[ "$os_name" == "linux" ]] &&include_os="linux"
        export CPPFLAGS="-I$JAVA_HOME/include -I$JAVA_HOME/include/$include_os"
        export CFLAGS="$CPPFLAGS"
        #echo "CPPFLAGS set for JDK $(basename $JAVA_HOME): $CPPFLAGS" >&2
    else
        #echo "JAVA_HOME not set or invalid — skipping CPPFLAGS" >&2
        unset CPPFLAGS CFLAGS
    fi
    }

    if ! [[ "$PROMPT_COMMAND" =~ jenv_post_global ]]; then
        PROMPT_COMMAND="${PROMPT_COMMAND}jenv_post_global;"
    fi

    #echo "PROMPT_COMMAND is $PROMPT_COMMAND"

    jenv_post_global
    ```  

+ Install latest openjdk  
    ```bash
    brew install openjdk
    sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
    ```  

+ Install another version of openjdk  
    ```bash
    brew install openjdk@21
    sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk
    ```  

+ Add multiple openjdk to jenv  
    ```bash
    jenv add /Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/
    jenv add /Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home/
    ```  

+ jenv operations
    <details>
        <summary>commands</summary>  

        ```txt
        | Operation | Command |  
        | -- | -- |  
        | Switch java to version 21 | jenv global 21 |  
        | Show the current Java version and its origin | jenv javahome |  
        | Check current java version in jenv  | jenv version |  
        | List all Java versions available to jenv | jenv versions |  
        | Check jenv status | jenv doctor |  
        ```
    </details>  

<details>
    <summary>Details</summary>

    ```txt
    For the system Java wrappers to find this JDK, symlink it with
    sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

    openjdk is keg-only, which means it was not symlinked into /opt/homebrew,
    because macOS provides similar software and installing this software in
    parallel can cause all kinds of trouble.

    If you need to have openjdk first in your PATH, run:
    echo 'export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"' >> /Users/mike/.bash_profile

    For compilers to find openjdk you may need to set:
    export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
    ```  

    在 macOS 上，“Java wrappers” 通常不是官方术语，但结合上下文（尤其是你之前提到 openjdk is keg-only 和 java -version 问题），你很可能指的是：  

    macOS 系统自带的 Java 启动器（launcher/wrapper） —— 即 /usr/bin/java 及其背后的 JavaVM.framework 机制。这是 Apple 在较老 macOS（如 macOS 10.7–10.14）中提供的 Java 运行时抽象层，用于透明地代理到已安装的 JDK（无论来自 Apple、Oracle、Homebrew、Eclipse Temurin 等）。  

    🔍 什么是 macOS 的 Java Wrapper / Java Launcher？  
    + /usr/bin/java 并不是一个真正的 JVM，而是一个 轻量级包装程序（wrapper），由 Apple 提供（位于 /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java）。  
    + 它会：  
        + 检查系统中已安装的 JDK（通过 /Library/Java/JavaVirtualMachines/ 下的目录）；  
        + 根据 JAVA_HOME、JVMVersion、JAVA_ARCH 等环境变量或配置，自动选择并启动合适的 JDK；  
        + 支持 -version, -XshowSettings:properties 等标准选项。  

    注意：自 macOS 10.15 Catalina 起，Apple 官方彻底移除了系统内置 JDK（包括 Java 6），/usr/bin/java 仅作为“代理”存在——它本身不提供 JVM，必须依赖用户手动安装的 JDK（如 Homebrew OpenJDK、Temurin 等）才能工作。  

    常见 wrapper 相关路径与作用  

    | 路径 | 类型 | 说明 |
    | -- | -- | -- |
    | /usr/bin/java | wrapper（launcher） | 系统入口，调用 JavaVM.framework 选 JDK |
    | /System/Library/Frameworks/JavaVM.framework/ | system framework | Apple 提供的 Java 抽象层（含 java, javac, keytool 等符号链接） |
    | /Library/Java/JavaVirtualMachines/ | JDK 安装根目录 | 所有第三方 JDK（如 temurin-21.jdk, zulu-17.jdk, openjdk-21.jdk）都放在这里 |
    | /opt/homebrew/opt/openjdk/libexec/openjdk.jdk | Homebrew OpenJDK 实际路径 | 因 keg-only，需手动配置 JAVA_HOME 指向此处 |  

    验证当前 wrapper 是否正常工作  
    1. 查看 wrapper 版本（实际调用的是你配置的 JDK）  
    /usr/bin/java -version  

    2. 查看它背后选中的真实 JDK 路径  
    /usr/bin/java -XshowSettings:properties -version 2>&1 | grep "java.home"  

    3. 列出所有已安装 JDK  
    /usr/libexec/java_home -V  

    /usr/libexec/java_home 是 macOS 的关键工具，可列出、查询、切换 JDK（例如：/usr/libexec/java_home -v 21 返回 JDK 21 路径）  

    ```txt
    ✅ 正确理解：/opt/homebrew/opt/openjdk/libexec/openjdk.jdk确实不是 JDK Home —— 你完全正确！
    Homebrew 安装 OpenJDK（如 openjdk@21）时，采用 keg-only 策略，其真实结构是：
    /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/     ← 这是一个 *symbolic link* 指向版本化路径
    └── Contents/
        ├── Home/                ← ✅ 这才是真正的 JDK home（含 bin/, lib/, jre/ 等）
        └── Info.plist, ...

    而 /opt/homebrew/opt/openjdk/libexec/openjdk.jdk 本身只是个「指向实际 JDK bundle 的软链」，它自己没有 Home/ 子目录；只有当你 cd 进入它并 ls，才看到 Contents/Home/ —— 所以：
    ❗️JAVA_HOME 必须指向 .../openjdk.jdk/Contents/Home（即 $JDK_PATH/Contents/Home），
    而不是 .../openjdk.jdk（这个路径下没有 bin/java，无法执行）。
    ✅ 验证方式：
    # 错误（不可执行 java）：
    $ /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/bin/java -version
    # → bash: /opt/.../openjdk.jdk/bin/java: No such file or directory

    # 正确（可执行）：
    $ /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home/bin/java -version
    # → openjdk version "21.0.2" ...

    ------------------------
    ✅ macOS Java Wrapper（/usr/bin/java）是否“知道”这个结构？
    是的，但前提是：你必须让系统“发现”这个 JDK。
    macOS 的 Java wrapper 本身不主动扫描 /opt/homebrew/... —— 它只信任标准位置：
    🔹 /Library/Java/JavaVirtualMachines/ ✅（系统级，全局可见）
    🔹 ~/Library/Java/JavaVirtualMachines/ ✅（用户级）
    → 所以你手动创建的符号链接：
    sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

    ✅ 正是让 wrapper “看见”该 JDK 的必要操作！
    （否则 /usr/libexec/java_home -V 根本不会列出它）
    但注意：即使 link 创建成功，wrapper 仍需满足：
    •  该 .jdk 目录下存在合法的 Contents/Info.plist（Homebrew 提供 ✔️）
    •  Contents/Home/ 存在且可读（✔️，你已验证）
    → 满足后，/usr/bin/java 就能通过 java_home 自动定位并调用 Contents/Home/bin/java。
    💡 可验证：
    # 查看 wrapper 是否识别到它
    /usr/libexec/java_home -V
    # 应输出类似：
    # Matching Java Virtual Machines (1):
    #     21.0.2, x86_64: "OpenJDK 21.0.2" /Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home

    # wrapper 是否可用？
    /usr/bin/java -version  # ✅ 应成功输出

    ------------------------
    🔁 总结：你做对了三件事
    | 步骤 | 作用 | 是否必要 |
    | 1️⃣ ln -sfn ... /Library/Java/JavaVirtualMachines/openjdk.jdk | 把 Homebrew JDK “注册”进 macOS JDK 发现机制 | ✅ 必须 |
    | 2️⃣ 理解 .../openjdk.jdk/Contents/Home 才是真正的 JAVA_HOME | 避免配置错误（如设成 .../openjdk.jdk 导致命令找不到） | ✅ 必须 |
    | 3️⃣ /usr/bin/java 会自动委托给 Contents/Home/bin/java | wrapper 的设计就是透明代理，无需额外配置 | ✅ 自动生效 |
    ------------------------
    需要我帮你：
    •  ✅ 自动生成一键修复脚本（检测 Homebrew JDK + 自动创建 link + 设置 JAVA_HOME）？
    •  ✅ 写一个 jenv 或 direnv 兼容的 .java-version 配置示例？
    •  ✅ 解释为什么 brew install openjdk 不自动 link 到 /Library/Java/...（安全策略 & keg-only 原因）？
    欢迎继续问！ 😊
    ```
</details>


## Install Go

