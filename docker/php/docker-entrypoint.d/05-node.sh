#!/bin/bash
set -e

cd ${PHP_PROJECT_ROOT}

NVM_DIR=/usr/local/nvm

function check_command_exists(){
  if ! command -v $1 &> /dev/null
  then
    # Return 1 = false
    return 1
  fi
  # Return 0 = false
  return 0
}

function can_install_node(){
  if [[ -z "${NODE_TAG}" || ! -n "${NODE_TAG}" ]]; 
  then 
    # var is empty. Return 1 = false
    return 1
  else
    # var is not empty. Return 0 = true
    return 0
  fi
}


function install_libraries(){

  if can_install_node; then
    if check_command_exists 'nvm';
    then
      echo "nvm already installed"
      nvm install ${NODE_TAG}
      nvm use ${NODE_TAG}
    else
      echo "installing nvm..."
      mkdir -p /usr/local/nvm
      mkdir -p /usr/local/node
      local profile_nvm="/etc/profile.d/nvm.sh"
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | NVM_DIR=$NVM_DIR bash
      
      chmod ugo+rwx $NVM_DIR/nvm.sh
      chmod ugo+rwx $NVM_DIR/bash_completion

      echo "#!/bin/bash" > ${profile_nvm}
      echo "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"  # This loads nvm" >> ${profile_nvm}
      echo "[ -s \"$NVM_DIR/bash_completion\" ] && source \"$NVM_DIR/bash_completion\"  # This loads nvm bash_completion" >> ${profile_nvm}

      chmod ugo+rwx ${profile_nvm}
      chown -R www-data:www-data $NVM_DIR      
      chown -R www-data:www-data ${profile_nvm}
      ${profile_nvm}
      chsh -s /bin/bash www-data
      #su www-data
      source ${profile_nvm}      
      nvm install ${NODE_TAG}
      nvm use ${NODE_TAG}
      #su -

      local wwwdata_profile_nvm="/home/www-data/.bashrc"
      sed -e '/# DOCKER_NVM/,/# \\DOCKER_NVM/d' ${wwwdata_profile_nvm}
      echo "" >> ${wwwdata_profile_nvm}
      echo "# DOCKER_NVM" >> ${wwwdata_profile_nvm}
      echo "[ -s \"$NVM_DIR/nvm.sh\" ] && source \"$NVM_DIR/nvm.sh\"  # This loads nvm" >> ${wwwdata_profile_nvm}
      echo "[ -s \"$NVM_DIR/bash_completion\" ] && source \"$NVM_DIR/bash_completion\"  # This loads nvm bash_completion" >> ${wwwdata_profile_nvm}
      echo "# \DOCKER_NVM" >> ${wwwdata_profile_nvm}
    fi
  fi
}

install_libraries