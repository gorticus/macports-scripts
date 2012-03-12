#!/bin/bash
#
# Baseline script to build and install scipy stack via macports
#
# Copyright (C) 2012 Jason Wm. Mitchell (jason-github@maiar.org)
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# hypothetical 10.7.x release that fixes LLVM virtual thunks
LLVM_VTHUNK_FIXED=2

# user version selection stuff for variants, etc.
vGCC=45
vPY=27

# commands
INSTALL="sudo port -d install"

# try to force explict use of specific compiler(s)
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++

function do_port()
{
  $INSTALL $*
  if [ $? -ne 0 ]; then
    echo "Error - install of '$1' failed."
    echo "Full command: $*"
    exit 1
  fi
}

# Mac OS X major version
MAJOR="$(sw_vers -productVersion| cut -d. -f1)"
MINOR="$(sw_vers -productVersion| cut -d. -f2)"
RELEASE="$(sw_vers -productVersion| cut -d. -f3)"
RELEASE=${RELEASE:-0}
vXCODE=$(xcodebuild -version | grep Xcode | cut -d\  -f2)

# checkt that macports can determine Xcode version
if [ -z "$vXCODE" ]; then
  echo "Unable to determine Xcode version, identify developer path:"
  echo "  xcode-select -switch <xcode_folder_path>"
  exit 1
fi

# ==================================
# misc, fairly independent, tools
do_port bash-completion
do_port bzip2 
do_port p7zip
do_port keychain
do_port hexedit
do_port elinks
do_port aspell aspell-dict-en

# basics (takes forever...)
do_port gcc${vGCC}
do_port python${vPY}
do_port boost +openmpi+python${vPY}+regex_match_extra
do_port atlas +gcc${vGCC}
do_port ghostscript  # you are here
do_port gcc_select
do_port python_select

# scipy stuff
do_port py${vPY}-numpy +atlas
do_port py${vPY}-scipy +atlas+gcc${vGCC}
do_port py${vPY}-ipython
do_port py${vPY}-spyder
do_port ipython_select

# 10.7.0+ & goes build issue: https://trac.macports.org/ticket/30309
if [ $MINOR -eq 7 -a $RELEASE -ge $LLVM_VTHUNK_FIXED ]; then
  GEOS_OPTS="configure.cc=$CC configure.cxx=$CXX"
fi
do_port geos $GEOS_OPTS
do_port py${vPY}-matplotlib # maybe useful: +ghostscript+latex+wxpython
do_port py${vPY}-matplotlib-basemap

# version control
do_port subversion +bash_completion+unicode_path
do_port git-core +bash_completion+doc+python${vPY}+svn
do_port git-flow
do_port GitX

# R
do_port R +aqua+gcc${vGCC}
