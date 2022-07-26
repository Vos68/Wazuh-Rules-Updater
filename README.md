# Wazuh-Rules-Updater
Small script centered on idea to keep repository with wazuh rules in git and update it automatically by cron.

Script checks main branch of gitlab repository with Wazuh rules for a changes. 

In case there are any changes - 
script starts a git synchronisation, 
validates rules throught Wazuh API call,
restarts Wazuh cluster. 

Status of update being notified to Matrix chat room.
Credentials for Wazuh API and Matrix are kept in dot-env files.

Install
Script runs on low privelege user account so you need to create it - 
adduser --disabled-password --shell /bin/bash --gecos "wazuh-rules-updater" wazuh-rules-updater

Sudoers modification required to run a fix for permissions. 
wazuh-rules-updater ALL=(root) NOPASSWD: /opt/wazuh-rules-updater/perm.sh
