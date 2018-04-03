## Python

### Description

The Blue Waters Python software stack (bwpy) is an expansive suite of Python software components
supporting a large class of high performance and scientific computing applications. The bwpy 
suite implements the [scipy stack specification](http://www.scipy.org/stackspec.html) plus many 
other scientific Python packages. Over 300 Python packages are avalable, including mpi4py, 
[pycuda](http://mathema.tician.de/software/pycuda/), [h5py](http://www.h5py.org/), 
[netcdf4-python](http://unidata.github.io/netcdf4-python/), and [pandas](http://pandas.pydata.org/).
The core numerical libraries are linked against Cray's libsci, and the stack is built for running
on both login and compute nodes.

### How to use the bwpy suite
The components of the bwpy suite are installed into two main modules, "bwpy" and "bwpy-mpi". The 
base module, "bwpy" provides the python interpreters plus most packages. The module "bwpy-mpi" adds
an additional Python sites directory at higher priority to override packages with optional MPI 
functionality and to proivide MPI-only modules such as mpi4py. This way, packages like mpi4py can 
be optionally imported and not break on login nodes. The "bwpy" module must be loaded first to gain
access to the "bwpy-mpi" module.

Besides bwpy, there are several other installations of Python, and so users should take care and 
ensure that they are using the correct Python software environment. Anaconda should not be used on
Blue Waters for it will not work well and is entirely unsupported. The paths to bwpy python will 
begin with either `/sw/bw/bwpy` or `/mnt/bwpy`. 

One may load bwpy with:

    :::bash
    $ module load bwpy

To load bwpy with MPI functionality:

    :::bash
    $ module load bwpy
    $ module load bwpy-mpi

After which, the path to the Python binary should be different:

    :::bash
    $ which python
    /mnt/bwpy/single/usr/bin/python
	
And the version reported by Python should be the latest version of the Python2 branch:

    :::bash
    $ python --version
    Python 2.7.14

### Entering the full bwpy environment with `bwpy-environ`

BWPY is now installed into ext3 images which must be mounted before use. This change dramatically
improves Python start-up times and allows for more frequent updates. To do this, a small program, 
`bwpy-environ`, is needed to perform these operations. It acts as a wrapper and should be invoked
as `bwpy-environ -- program [args...]`. If no arguments are given, it will open a new bash instance
within the mount namespace it creates, which is useful for interactive tasks. There are some 
wrappers for some commonly used executables, but bwpy-environ is needed to access the full range of
executables and should be used if python is to be invoked multiple times.

Note: It is necessary to pass `aprun` the `-b` flag for `bwpy-environ` to run with the correct 
permissions.

#### Example 1:

    :::bash
    $ aprun -b -n 1 -- bwpy-environ -- python -c "import numpy"

#### Example 2:

    :::bash
    $ aprun -b -n 1 -- bwpy-environ -- myscript.sh
    $ cat myscript.sh
    #!/bin/bash
    python script1.py
    python script2.py

When possible, it is still advisable to condense multiple invocations of Python into a single Python
script. 

#### Example:

job.pbs:

    :::bash
    ...
    module load bwpy
    aprun -b -n 1 bwpy-environ myscript.sh

myscript.sh:

    :::bash
    #!/bin/bash
    for i in {0..999}; do python script1.py; done
    for i in {0..499}; do python script2.py; done

script1.py:

    :::python
    #!/usr/bin/env python
    import sys
    print("script 1 %s" % sys.argv[1])

script2.py:

    :::python table
    #!/usr/bin/env python
    import sys
    print("script 2 %s" % sys.argv[1])

This should be rewritten to:

myscript.sh:

    :::bash
    #!/bin/bash
    python outer.py

outer.py:

    :::python
    #!/usr/bin/env python
    from script1 import script1_main
    from script2 import script2_main
    def outer_main(range1,range2):
        for i in range(range1):
            script1_main(i)
        for i in range(range2):
            script2_main(i)
    if __name__ == "__main__":
        import sys
        outer_main(int(sys.argv[1]),int(sys.argv[2]))

script1.py:

    :::python
    #!/usr/bin/env python
    def script1_main(arg):
        print("script 1 %s" % arg)
    if __name__ == "__main__":
        import sys
        script1_main(sys.argv[1])

script2.py:

    :::python
    #!/usr/bin/env python
    def script2_main(arg):
        print("script 2 %s" % arg)
    if __name__ == "__main__":
        import sys
        script2_main(sys.argv[1])

This can be made to run in parallel with minimal changes:

outer.py:

    :::python
    #!/usr/bin/env python
    import os
    from script1 import script1_main
    from script2 import script2_main
    
    pes = int(os.environ.get("PBS_NP",1))
    rank = int(os.environ.get("ALPS_APP_PE",0))
    
    def outer_main(range1,range2):
        for i in range(range1):
            if i % pes == rank:
                script1_main(i)
        for i in range(range2):
            if i % pes == rank:
                script2_main(i)
    
    if __name__ == "__main__":
        import sys
        outer_main(int(sys.argv[1]),int(sys.argv[2]))

### Python Implementations and Packages

The bwpy module provides several implementations and versions of Python. Those in the
latest release are:

* Python 2.7
* Python 3.5
* Pypy
* Pypy3

***[Note that Python 2 is End of Life!!!](https://pythonclock.org/) All Python 2 
programs should be migrated to Python 3!***

These can be accessed via `python`, `python2`, `python3`, `python2.7`, `python3.5`, 
`python3.6`, `pypy`, `pypy3`. The default `python` is Python 2 and the default
`python3` is 3.5. 

The default `python` version can be changed by exporting `EPYTHON=pythonver`.  This is also
reflected in the execution of interpreted programs of bwpy, such as `jupyter-notebook`:

    :::bash
    $ python --version
    Python 2.7.14
    $ EPYTHON="python3.5" python --version
    Python 3.5.4
    $ jupyter-notebook                   # Python 2.7 notebook
    $ EPYTHON="python3.5" jupyter-notebook # Python 3.5 notebook

It is recommended to use `#!/usr/bin/env python`, `#!/usr/bin/env python2` or 
`#!/usr/bin/env python3` for your shebangs depending on your code compatibility.

To list the available packages for each implementation, use the command `pip list`. Pypy and
pypy3 only have a limited numpy implementation, but is much better optimized than CPython 
with JIT compilation to machine code.

### Virtualenv

Simply being able to use the pip and python executables is enough for most users. However, 
the bwpy module also supports the usage of virtualenv. Virtualenv must be used within 
`bwpy-environ`.

Virtualenv creates Python containers for building multiple Python environments with different
packages and package versions. The containers have python and pip wrappers which set up 
the environment for the active virtualenv. For information on virtualenv, please read 
[its package documentation](https://virtualenv.readthedocs.org/en/latest/).

### Building software against bwpy libraries

To build software against the bwpy libraries, use the `PrgEnv-gnu` compiler environment and
export the following variables:

    :::bash
    $ export CPATH="${BWPY_INCLUDE_PATH}"
    $ export LIBRARY_PATH="${BWPY_LIBRARY_PATH}"
    $ export LDFLAGS="${LDFLAGS} -Wl,--rpath=${BWPY_LIBRARY_PATH}"

A `bwpy-environ` session is required to make `/mnt/bwpy` accessible.

These paths are treated as system paths for bwpy. Using `CPATH` and `LIBRARY_PATH` will 
ensure that these paths are searched after any `-I` and `-L` options for correctness. The
CMake in bwpy also treats these paths as system paths for the same reason, and won't generate
`-I` or `-L` flags for libraries in these paths. Thus, these environment variables must be
set for bwpy's CMake to function correctly.


### Known Limitations

* Applications that use Tkinter, matplotlib, or any other GUI backend will require a connection to a properly configured X server.
* MPI applications will not run on a login node, but must be ran in a job using aprun. This restriction exists even for runs with only one rank.

### Resources

* [Examples using numpy](http://wiki.scipy.org/Numpy_Example_List)
* [Scipy Central](http://scipy-central.org/)
* [Matplotlib examples](http://matplotlib.org/examples/)
* [MPI tutorial](http://mpi4py.scipy.org/docs/usrman/tutorial.html)

