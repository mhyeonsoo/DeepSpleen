FROM nvidia/cuda:8.0-cudnn5-devel

RUN apt-get -y update && \ 
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends apt-utils &&\
    apt-get -y install wget bc &&\
    apt-get -y install zip unzip &&\
    apt-get -y install libxt-dev &&\
    apt-get -y install libxext6 &&\
    apt-get -y install libglu1 &&\
	apt-get install libstdc++6 &&\
    apt-get -y install libxrandr2 &&\    
    apt-get -y install ghostscript &&\
    apt-get -y install imagemagick &&\
	mkdir /tmp/matlab_mcr && \
    cd /tmp/matlab_mcr/ && \
    wget -nv http://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/glnxa64/MCR_R2016a_glnxa64_installer.zip && \
    unzip MCR_R2016a_glnxa64_installer.zip && \
    ./install -agreeToLicense yes -mode silent && \
    rm -rf /tmp/matlab_mcr
#    apt-get -y install python2.7 &&\
#    apt-get -y install python-pip


# Install Miniconda
RUN mkdir /tmp/miniconda &&\
    cd /tmp/miniconda &&\
    apt-get install bzip2 &&\
    wget -nv https://repo.continuum.io/miniconda/Miniconda2-4.3.30-Linux-x86_64.sh  --no-check-certificate &&\
    chmod +x Miniconda2-4.3.30-Linux-x86_64.sh &&\
    bash Miniconda2-4.3.30-Linux-x86_64.sh -b -p ~/miniconda &&\
    rm -r /tmp/miniconda

# Create a Python 2.7 environment
#RUN ~/miniconda/bin/conda install conda-build -y &&\
#    ~/miniconda/bin/conda create -y --name python27 python=2.7

# install Python packages
RUN ~/miniconda/bin/pip install http://download.pytorch.org/whl/cu80/torch-0.2.0.post3-cp27-cp27mu-manylinux1_x86_64.whl &&\
    ~/miniconda/bin/pip install torchvision &&\
    ~/miniconda/bin/pip install pytz &&\
    ~/miniconda/bin/pip install nibabel &&\
    ~/miniconda/bin/pip install tqdm &&\
    ~/miniconda/bin/pip install h5py &&\
    ~/miniconda/bin/pip install scipy

ENV PATH /root/miniconda/bin:${PATH}
#ENV PATH ~/miniconda/envs/python27/bin:${PATH}
ENV CONDA_DEFAULT_ENV python27
ENV CONDA_PREFIX ~/miniconda/envs/python27


RUN mkdir /INPUTS && \
    mkdir /OUTPUTS && \
    mkdir /extra

# Copy binaries and other files
ADD extra /extra

# Set environment for MATLAB MCR
ENV LD_LIBRARY_PATH /usr/local/MATLAB/MATLAB_Runtime/v901/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v901/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v901/sys/os/glnxa64:${LD_LIBRARY_PATH}


# Set up FSL
ENV PATH "${PATH}:/extra/fsl_510_eddy_511/bin"
ENV FSLDIR /extra/fsl_510_eddy_511

# Do Singularity hack
ENV SINGULARITY TRUE



