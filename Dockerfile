# Using the Ubuntu image
FROM ubuntu:14.04

MAINTAINER Dietmar Winkler <dietmar.winkler@dwe.no>

# Make sure apt is up to date
RUN apt-get update
RUN apt-get upgrade -y

# Not essential, but wise to set the lang
RUN apt-get install -y language-pack-en
ENV LANGUAGE en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LC_ALL en_GB.UTF-8

RUN locale-gen en_GB.UTF-8
RUN dpkg-reconfigure locales

# Python binary dependencies, developer tools
RUN apt-get install --no-install-recommends -y -q build-essential make gcc \
    zlib1g-dev git mencoder imagemagick inkscape\
    libzmq3-dev sqlite3 libsqlite3-dev pandoc libcurl4-openssl-dev nodejs \
    texlive-latex-extra texlive-fonts-recommended dvipng libfreetype6-dev \
    python python-dev python-pip python-wand python-numpy python-scipy \
    python-matplotlib ipython ipython-notebook python-pandas python-sympy \
    python-nose python-pygments python-tk

# First upgrade the system ipython including dependencies
RUN pip install --upgrade ipython[notebook]

# upgrade the newest ipython version 3-dev from the repo
RUN mkdir /opt/ipython
RUN git clone --depth 1 --recursive https://github.com/ipython/ipython.git /opt/ipython
WORKDIR /opt/ipython
RUN pip install --upgrade -e ".[notebook]"

# VOLUME /notebooks  # Don't use Volume as we do not need persistent data

EXPOSE 8888

# You can mount your own SSL certs as necessary here
ENV PEM_FILE /key.pem
ENV PASSWORD Dont make this your default

# Create a directory for all the book related stuff
RUN useradd student
RUN mkdir /opt/notebooks
RUN chown student /opt/notebooks
ADD notebook.sh /opt/
RUN chown student /opt/notebook.sh
RUN chmod u+x /opt/notebook.sh

USER student

WORKDIR /opt/notebooks

CMD /opt/notebook.sh
