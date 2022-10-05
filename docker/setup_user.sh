#!/bin/bash

# Exit on error
set -o errexit
set -o errtrace

# Enable tracing of what gets executed
#set -o xtrace

useradd -m -G wheel -d ${USER_HOME} -s /bin/bash ${USER}
chown -R ${USER} ${USER_HOME}
