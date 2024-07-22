# Jupyter

## Install Jupyter
### Install and run jupyter in python virtual environment

> https://medium.com/@WamiqRaza/how-to-create-virtual-environment-jupyter-kernel-python-6836b50f4bf4  

+ Create python virtual environment myenv  
    ```bash
    python -m venv myenv
    ```  

+ Activate virtual environment  
    ```bash
    source myenv\bin\activate
    ```  

    > Deactivate virtual environment:  
    ```bash
    deactivate
    ```  

+ Install Jupyter within virtual environment  
    ```bash
    pip install jupyter
    ```  

+ Install Kernel (within the virtual environment)  
    You will need to install the IPython kernel in your virtual environment to use it with Jupyter.  

    ```bash
    pip install ipython
    pip install ipykernel
    ipython kernel install --user --name=myenv
    python -m ipykernel install --user --name=myenv
    ```  

    > Replace myenv with the name you want for your Jupyter kernel.  

+ Install the Bash Kernel  
    ```bash
    pip install bash_kernel
    python -m bash_kernel.install
    ```  

+ Start jupyter  
    ```bash
    jupyter notebook
    ```  

+ Select the Virtual Environment Kernel in Jupyter  
    1. Open a browser window with the Jupyter interface.  
    2. Navigate to the notebook or create a new one.  
    3. lick on the “Kernel” menu.  
    4. Choose “Change Kernel” and select the virtual environment kernel you created (in this case, it will be named “myenv”).  
    
    Now, your Jupyter notebook will be using the Python environment from your virtual environment.  

    To check if bash is install and working correctly run below command  
    ```bash
    %%bash
    echo "Hello from Bash!"
    ```  