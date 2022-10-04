#!/bin/bash

# Exit on error
set -o errexit
set -o errtrace

# Enable tracing of what gets executed
#set -o xtrace

useradd -m -G wheel -d ${USER_HOME} -s /bin/bash ${USER}
chown -R ${USER} ${USER_HOME}

# echo 'root ALL=(ALL) NOPASSWD: ALL' >> ./root
# sudo chown root:root ./root
# sudo mv ./root /etc/sudoers.d/

# echo '${USER} ALL=(ALL) NOPASSWD: ALL' >> ./${USER}
# sudo chown root:root ./${USER}
# sudo mv ./${USER} /etc/sudoers.d/