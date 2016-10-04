# ----------------------------------------------------------------------
# Numenta Platform for Intelligent Computing (NuPIC)
# Copyright (C) 2015, Numenta, Inc.  Unless you have purchased from
# Numenta, Inc. a separate commercial license for this software code, the
# following terms and conditions apply:
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# http://numenta.org/licenses/
# ----------------------------------------------------------------------

"""fix DATETIME and TIMESTAMP defaults

Revision ID: 872a895b8e8
Revises: 1d2eddc43366
Create Date: 2016-05-11 18:42:24.861060
"""

from alembic import op
import sqlalchemy as sa


# Revision identifiers, used by Alembic. Do not change.
revision = '872a895b8e8'
down_revision = '1d2eddc43366'



def upgrade():
    """Fix server defaults for DATETIME columns, because
    0 ("0000-00-00 00:00:00") is deprecated as default for those colum types
    as of mysql 5.7.8, and will fail with mysql installed with default config.
    """
    op.alter_column("instance_status_history", "timestamp",
                    server_default=None,
                    existing_type=sa.DATETIME,
                    existing_nullable=False)



def downgrade():
    raise NotImplementedError("Rollback is not supported.")
