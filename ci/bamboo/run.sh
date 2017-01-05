#!/bin/bash
# ----------------------------------------------------------------------
# Numenta Platform for Intelligent Computing (NuPIC)
# Copyright (C) 2016-2017, Numenta, Inc.  Unless you have purchased from
# Numenta, Inc. a separate commercial license for this software code, the
# following terms and conditions apply:
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero Public License for more details.
#
# You should have received a copy of the GNU Affero Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# http://numenta.org/licenses/
# -----------------------------------------------------------------------------

# Note:  This script assumes that it is being run in a bamboo build plan in
# which the Source Code Checkout task has been configured to also check out the
# following repositories:
#   numenta/nupic.core
#   numenta/nupic
#   numenta/numenta-apps
#
# This script will exercise the instructions in the README up to the point of
# actually running services to ensure that instructions for setup, particularly
# with respect to configuration and database migrations are functional

# Setup dependencies
pushd nupic.core
./ci/bamboo/setup-dependencies-linux.sh
popd
rm -rf nupic.core

pushd nupic
./ci/bamboo/configure-build-ubuntu.sh
./ci/bamboo/configure-test-ubuntu.sh
popd
rm -rf nupic

apt-get install -y libmysqlclient-dev

# Install latest, release-version nupic from pypi w/ pip
pip install nupic

pushd numenta-apps/nta.utils
python setup.py develop --user
popd

pushd numenta-apps/htmengine
python setup.py develop --user
popd

# Configure skeleton htmengine app
pushd skeleton-htmengine-app
pip install -r requirements.txt
export APPLICATION_CONFIG_PATH=`pwd`/conf
python -c 'import os, ConfigParser; config=ConfigParser.ConfigParser(); config.read("conf/model-checkpoint.conf"); config.set("storage", "root", os.path.join(os.getcwd(), "model_checkpoints")); config.write(open("conf/model-checkpoint.conf", "w"));'
python -c 'import os, ConfigParser; config=ConfigParser.ConfigParser(); config.read("conf/supervisord.conf"); config.set("supervisord", "environment", "APPLICATION_CONFIG_PATH=" + os.environ["APPLICATION_CONFIG_PATH"]); config.write(open("conf/supervisord.conf", "w"));'
mysql -u root --execute="CREATE DATABASE skeleton"
python repository/migrate.py
popd
