# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:/home/common/mpich-3/bin:$HOME/bin
PATH=$PATH:/usr/local/cuda-5.5/bin
LD_LIBRARY_PATH=/usr/local/cuda-5.5/lib64:/lib

export LD_LIBRARY_PATH

export PATH

export MPICH_PORT_RANGE=10000:10100


