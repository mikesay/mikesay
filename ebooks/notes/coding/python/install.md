# Python Installation

## Mac
### Using brew
+ Search latest python  
    ```bash
    brew search python
    ```  

+ Install latest python using brew  
    ```bash
    brew install python@3.12
    ```  

    > Output:  
    ```txt
    Error: The `brew link` step did not complete successfully
    The formula built, but is not symlinked into /usr/local
    Could not symlink bin/2to3
    Target /usr/local/bin/2to3
    already exists. You may want to remove it:
    rm '/usr/local/bin/2to3'

    To force the link and overwrite all conflicting files:
    brew link --overwrite python@3.12

    To list all files that would be deleted:
    brew link --overwrite python@3.12 --dry-run

    Possible conflicting files are:
    /usr/local/bin/2to3 -> /Library/Frameworks/Python.framework/Versions/3.8/bin/2to3
    /usr/local/bin/idle3 -> /Library/Frameworks/Python.framework/Versions/3.8/bin/idle3
    /usr/local/bin/pydoc3 -> /Library/Frameworks/Python.framework/Versions/3.8/bin/pydoc3
    ==> /usr/local/Cellar/python@3.12/3.12.4/bin/python3.12 -Im ensurepip
    ==> /usr/local/Cellar/python@3.12/3.12.4/bin/python3.12 -Im pip install -v --no-index --upgrade --isolated --target=/usr/local/lib/python3.12/site-packages /usr/local/Cellar/python@3.12/3.12.4/Frameworks/
    ==> Caveats
    Python has been installed as
    /usr/local/bin/python3

    Unversioned symlinks `python`, `python-config`, `pip` etc. pointing to
    `python3`, `python3-config`, `pip3` etc., respectively, have been installed into
    /usr/local/opt/python@3.12/libexec/bin

    See: https://docs.brew.sh/Homebrew-and-Python
    ==> Summary
    🍺  /usr/local/Cellar/python@3.12/3.12.4: 3,277 files, 61.7MB
    ==> Running `brew cleanup python@3.12`...
    ```  

+ Setup brew link for installed python according to the installation output  
    ```bash
    brew link --overwrite python@3.12
    ```  

+ Add path unversioned python executables into environment PATH  
    ```bash
    export PATH=/usr/local/opt/python/libexec/bin:$PATH >> ~/.bash_profile
    ```  

+ Check python paths  
    ```bash
    python -m site
    ```  