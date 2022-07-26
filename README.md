# Wazuh Rules Updater
Small script centered on idea to keep repository with [Wazuh](https://wazuh.com/) server rules in git and update it automatically by cron.

Script checks main branch of gitlab repository with Wazuh rules for a changes. 

In case there are any changes:
- Script starts a git synchronisation 
- Validates rules throught Wazuh API call
- Restarts Wazuh cluster
- Status of update being notified to [Matrix](https://matrix.org/) chat room

Credentials for Wazuh API and Matrix are being kept in dot-env files.

Push root of rules folder <b>/var/ossec/etc</b> on Wazuh master server to a repo in gitlab any acceptable way.
You may desire to keep it low privelege as possible so read http token is plenty enough.
 
To avoid clent/server keys and generated configs being pushed to git I advice to create <b>.gitignore</b> file for <b>/var/ossec/etc</b> with strings:
```
client.keys*
sslmanager.*
ossec.*
local*
shared*
resolv*
internal*
rootcheck*
```
## Example of repository with rules for Wazuh server
```
.
├── decoders
│   ├── custom_decoder.xml
├── lists
│   └── suspicious-programs
└── rules
    ├── 0015-ossec_custom_rules.xml
```

## Install
```
git clone https://github.com/Vos68/Wazuh-Rules-Updater /opt/wazuh-rules-updater
```
Edit credentials in files
```
vi /opt/wazuh-rules-updater/.env
vi /opt/wazuh-rules-updater/.envr
```

Keep permissions limited as possible
```
chmod 100 /opt/wazuh-rules-updater/perm.sh
```

Create low privelege user account
```
adduser --disabled-password --shell /bin/bash --gecos "wazuh-rules-updater" wazuh-rules-updater
```

Sudoers modification required to run a fix for permissions. 
```
wazuh-rules-updater ALL=(root) NOPASSWD: /opt/wazuh-rules-updater/perm.sh
```

Add script to cron 
```
*/5 *   * * *   wazuh-rules-updater /usr/bin/bash /opt/wazuh-rules-updater/wazuh-rules-updater.sh
```
