## Cross platform code to support getting home directory
```sh
from os.path import expanduser
home = expanduser(os.path.join("~", "myarchive")
```

## Python clousure
 Inner method can read-access variable of outter method, but can't write-access it. If you want to write-access, you have to wrap the outter variable in a mutalbe object.

## Python global variable
You have to use keyward global in your local scope to state that you are writing to global variable instead of local variable.
