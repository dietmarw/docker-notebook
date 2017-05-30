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
RUN apt-get update --fix-missing && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
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
ENV SHELL /bin/bash
ENV USER student
ENV PATH $CONDA_DIR/bin:$PATH
WORKDIR $HOME

RUN conda install --yes jupyter \
                        matplotlib \
                        numpy \
                        pandas \
                        scipy \
                        sympy \
                        terminado && \
    conda clean -yt

RUN pip install version_information

# Workaround for issue with ADD permissions
USER root
RUN chown student:student /home/student -R
COPY ./setup.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/setup.sh
RUN mkdir /home/student/letsencrypt
COPY /etc/letsencrypt/live/jupyter.dwe.no/*.pem /home/letsencrypt/

# set git-sh as default shell
ENV SHELL /usr/bin/git-sh

USER student

# When run with orchestrate.py the following command will not be executed.
# See '--command' option instead
CMD /usr/local/bin/setup.sh
