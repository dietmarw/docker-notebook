# Using the Ubuntu image
FROM ubuntu:14.04

MAINTAINER IPython Project <ipython-dev@scipy.org>

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
RUN apt-get install -y -q build-essential make gcc zlib1g-dev git python python-dev python-pip
RUN apt-get install -y -q libzmq3-dev sqlite3 libsqlite3-dev pandoc libcurl4-openssl-dev nodejs
RUN apt-get install -y -q texlive-latex-extra texlive-fonts-recommended dvipng libfreetype6-dev
RUN apt-get install -y -q python-numpy python-scipy python-matplotlib ipython ipython-notebook python-pandas python-sympy python-nose

# upgrade the slightly outdated ipython from the repo
RUN pip install --upgrade ipython[notebook]

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
