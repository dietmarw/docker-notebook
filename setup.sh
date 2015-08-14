#!/bin/bash

git clone --depth 1 https://github.com/dietmarw/tutorialtest /home/student/notebooks/EK5312

# # Convert notebooks to the current format
# find . -name '*.ipynb' -exec ipython nbconvert --to notebook {} --output {} \;
# find . -name '*.ipynb' -exec ipython trust {} \;

# # make notebook files read only
# chmod a-w /home/student/notebooks/EK5312/Chapman/*.ipynb

username=`shuf -n 1 /usr/share/dict/american-english | sed -e "s/'.*//"`

git config --global user.name "`echo $username`"
git config --global user.email "`echo $username`@example.org"
git config --global credential.helper 'cache --timeout=36000'
git config --global github.user 'modelica2015'

git clone https://github.com/modelica2015/tutorial

cat  >> /home/student/.bashrc <<EOF
echo
echo "******************************************"
echo "* Welcome to the Git and GitHub tutorial *"
echo "*    at the Modelica Conference 2015.    *"
echo "******************************************"
echo
echo " Your git username for this session is:"
echo
echo "            $username"
echo
EOF
