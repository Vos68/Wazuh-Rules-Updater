#!/bin/bash
envr=/opt/wazuh_rules_updater/.envr
if [[ -r $envr ]] ; then
     . "$envr"
else
     /usr/bin/echo "env file not found or not readable."
     logger -p local0.notice -t ${0##*/}[$$] env file not found or not readable
     exit 1
fi
cd /var/ossec/etc
BEFORE=$(/usr/bin/git rev-parse HEAD)
/usr/bin/git reset HEAD --hard
/usr/bin/git fetch -q
/usr/bin/git merge -q
AFTER=$(/usr/bin/git rev-parse HEAD)
/usr/bin/sudo /opt/wazuh_rules_updater/perm.sh
#logger -p local0.notice -t ${0##*/}[$$] Git requested.
if [ "$BEFORE" == "$AFTER" ]; then
        exit 1
else
#       logger -p local0.notice -t ${0##*/}[$$]  Validating rules
        /usr/bin/echo '{"message": "Wazuh updated rules from git. Validating...."}' | /usr/bin/python3 /opt/wazuh_rules_updater/send_to_matrix.py
        TOKEN=$(/usr/bin/curl -s -u $u:$p -k -X GET "https://127.0.0.1:55000/security/user/authenticate?raw=true")
                while true; do
                        sleep 7
                        ANSWER=$(/usr/bin/curl -s -k -X \
                        GET "https://localhost:55000/cluster/configuration/validation" \
                        -H  "Authorization: Bearer $TOKEN" \
                        -H  "Content-Type: application/json" | \
                        /usr/bin/jq -r '.data.affected_items[0].status')
                        if [ -z "$ANSWER" ]
                        then
                                sleep 15
                        elif [[ "$ANSWER" == "OK" ]]
                        then
                                ANSWER=$(/usr/bin/curl -s -k -X PUT "https://localhost:55000/cluster/restart" -H  "Authorization: Bearer $TOKEN"  -H "Content-Type: application/json")
                                /usr/bin/echo '{"message": "Successfully updated cluster"}' | /usr/bin/python3 /opt/wazuh_rules_updater/send_to_matrix.py
                                break
                        else
                                ANSWERERR=$(/usr/bin/curl -s -k -X \
                                GET "https://localhost:55000/cluster/configuration/validation" \
                                -H  "Authorization: Bearer $TOKEN" \
                                -H  "Content-Type: application/json" | \
                                /usr/bin/jq -r '.data.failed_items[0].error')
                                /usr/bin/echo $ANSWERERR  | /usr/bin/python3 /opt/wazuh_rules_updater/send_to_matrix.py
                                break
                        fi
                done
fi
exit 1
