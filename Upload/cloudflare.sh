#!/bin/bash auth_email=chakuza111@gmail.com # The email used to login 'https://dash.cloudflare.com' auth_key=0580969730a2a9e91842965650f28075ef140 # Top right corner, "My profile" > "Global API Key" zone_identifier=56788707384f94c2e72c726bc34090e3 # Can be found in the "Overview" tab of your domain record_name=www.vitaforas.de # Which record you want to be synced proxy=true # Set the proxy to true or false ########################################### ## Check if we have a public IP ########################################### ip=$(curl -s https://ipv4.icanhazip.com/ || curl -s https://api.ipify.org) if [ "${ip}" == "" ]; then message="No public IP found." >&2 echo -e "${message}" >> ~/log exit 1 fi ########################################### ## Seek for the A record ########################################### echo " Check Initiated" >> ~/log record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json") ########################################### ## Set the record identifier from result ########################################### record_identifier=$(echo "$record" | grep -Po '(?<="id":")[^"]*' | head -1) ########################################### ## Change the IP@Cloudflare using the API ########################################### update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" --data "{\"type\":\"A\",\"proxied\":${proxy},\"name\":\"$record_name\",\"content\":\"$ip\"}") ########################################### ## Report the status ########################################### case "$update" in *""success":false"*) message="$ip $record_name DDNS failed for $record_identifier ($ip). DUMPING RESULTS:n$update" >&2 echo -e "${message}" >> ~/log exit 1;; *) message="$ip $record_name DDNS updated." echo "${message}" >> ~/log exit 0;; esac