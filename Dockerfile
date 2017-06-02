# Base image of the IPython/Jupyter notebook, with conda
# Intended to be used in a tmpnb installation
# Based on https://github.com/jupyter/docker-demo-images

# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.22

MAINTAINER Dietmar Winkler <dietmar.winkler@dwe.no>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive
USER root

# Make sure apt is up to date
RUN add-apt-repository 'deb http://build.openmodelica.org/apt xenial stable'
RUN curl -s http://build.openmodelica.org/apt/openmodelica.asc | apt-key add -
RUN apt-get update --fix-missing && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# Install OpenModelica components
RUN apt-get install -y omc omlib-modelica-3.2.2 omniorb python-omniorb omniidl omniidl-python

# Install rest of base system
RUN apt-get install -y \
        bzip2 \
        ca-certificates \
        ffmpeg \
        git \
        git-sh \
#        inkscape \
        mc \
        pandoc \
        texlive \
        texlive-latex-extra \
        tig #\
#        wamerican

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV CONDA_DIR /opt/conda

# Install conda for the student user only (this is a single user container)
RUN echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh && \
    curl -O -s https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash /Miniconda3-latest-Linux-x86_64.sh -b -p $CONDA_DIR && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda install --yes conda

# We run our docker images with a non-root user as a security precaution.
# student is our user
RUN useradd -m -s /bin/bash student
RUN chown -R student:student $CONDA_DIR

EXPOSE 8888

USER student
ENV HOME /home/student
# set git-sh as default shell
ENV SHELL /usr/bin/git-sh
#ENV SHELL /bin/bash
ENV USER student
ENV PATH $CONDA_DIR/bin:$CONDA_DIR/envs/py2/bin:$CONDA_DIR/envs/py3/bin:$PATH
WORKDIR $HOME

RUN conda install --yes jupyter \
                        matplotlib \
                        numpy \
                        pandas \
                        scipy \
                        sympy \
                        terminado && \
    conda clean -yt
RUN conda create -n py2 python=2 ipykernel
RUN source activate py2 &&\
    ipython kernel install --user
RUN conda create -n py3 python=3 ipykernel
RUN python source activate py3 &&\
    ipython kernel install --user
RUN pip install version_information
RUN pip install git+git://github.com/OpenModelica/OMPython.git

# Workaround for issue with ADD permissions
USER root
RUN mkdir /etc/letsencrypt
COPY fullchain.pem /etc/letsencrypt/
COPY privkey.pem /etc/letsencrypt/
# RUN chmod o-r /etc/letsencrypt/*

RUN chown student:student /home/student -R
COPY ./setup.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/setup.sh

USER student

# When run with orchestrate.py the following command will not be executed.
# See '--command' option instead
CMD /usr/local/bin/setup.sh
