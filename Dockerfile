# A dockerfile must always start by importing the base image.
# We use the keyword 'FROM' to do that.
# In our example, we want import the python image.
# So we write 'python' for the image name and 'latest' for the version.
FROM pymesh/pymesh

# In order to launch our python code, we must import it into our image.
# We use the keyword 'COPY' to do that.
# The first parameter 'main.py' is the name of the file on the host.
# The second parameter '/' is the path where to put the file on the image.
# Here we put the file at the image root folder.

#RUN git clone --single-branch https://github.com/LPDI-EPFL/masif

# install necessary dependencies
RUN apt-get update && \
	apt-get install -y wget git unzip cmake vim libgl1-mesa-glx dssp
	
# DOWNLOAD/INSTALL APBS
RUN mkdir /install
WORKDIR /install
RUN git clone https://github.com/Electrostatics/apbs-pdb2pqr
WORKDIR /install/apbs-pdb2pqr
RUN ls
RUN git checkout b3bfeec
RUN git submodule init
RUN git submodule update
RUN ls
RUN cmake -DGET_MSMS=ON apbs
RUN make
RUN make install
RUN cp -r /install/apbs-pdb2pqr/apbs/externals/mesh_routines/msms/msms_i86_64Linux2_2.6.1 /root/msms/
RUN curl https://bootstrap.pypa.io/pip/3.6/get-pip.py -o get-pip.py
RUN python get-pip.py

# INSTALL PDB2PQR
WORKDIR /install/apbs-pdb2pqr/pdb2pqr
RUN git checkout b3bfeec
RUN python2.7 scons/scons.py install

# Setup environment variables 
ENV MSMS_BIN /usr/local/bin/msms
ENV APBS_BIN /usr/local/bin/apbs
ENV MULTIVALUE_BIN /usr/local/share/apbs/tools/bin/multivalue
ENV PDB2PQR_BIN /install/apbs-pdb2pqr/pdb2pqr/pdb2pqr.py

# DOWNLOAD reduce (for protonation)
WORKDIR /install
RUN git clone https://github.com/rlabduke/reduce.git
WORKDIR /install/reduce
RUN make install
RUN mkdir -p /install/reduce/build/reduce
WORKDIR /install/reduce/build/reduce
RUN cmake /install/reduce/reduce_src
WORKDIR /install/reduce/reduce_src
RUN make
RUN make install

# Install python libraries
RUN pip3 install matplotlib 
RUN pip3 install ipython Biopython scikit-learn tensorflow==1.12 networkx open3d==0.8.0.0 dask==1.2.2 packaging
#RUN pip install StrBioInfo 

# Clone masif
WORKDIR /

# prepend /usr/local/bin to PATH
ENV PATH="/usr/local/bin:$PATH"

# # Copy newer GLIBC from Ubuntu 22.04
COPY --from=ubuntu:22.04 /lib/x86_64-linux-gnu/libc.so.6 /usr/lib/x86_64-linux-gnu/libc.so.6

# We need to define the command to launch when we are going to run the image.
# We use the keyword 'CMD' to do that.
CMD [ "bash" ]
