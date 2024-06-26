#!/usr/bin/bash

#                       Service/virus-total-ip.sh
#                       
#                       this script uses the virustotal api_key 
#                       and finds any of the IP addresses connected
#                       to the system and finds if they are malicious 
#                       or not.
#
#                       by: martin-montas
#

check_ip_malicious() {
    local api_key="$1"
    local ip_address="$2"
    local url="https://www.virustotal.com/api/v3/ip_addresses/${ip_address}"
    local response=$(curl -s -H "x-apikey: ${api_key}" "${url}")

    # Check if response contains data
    if [[ "${response}" == *"\"data\":"* ]]; then
        # Parse JSON response to check for malicious detections
        malicious=$(echo "${response}" | jq -r '.data.attributes.last_analysis_stats.malicious')

        if [[ "${malicious}" -gt 0 ]]; then
            echo "The IP address '${ip_address}' is malicious."
        else
            echo "The IP address '${ip_address}' is not malicious."
        fi
    else
        echo "Error: Failed to retrieve information for IP address '${ip_address}'."
    fi
}

# Set your VirusTotal API key
api_key="api key"
IP_TO_CHECK=$(ss -t | awk '{print $5}' | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
IPV6_TO_CHECK=$(ss -t | awk '{print $5}' | grep -oE  '\[[0-9a-fA-F:]+\]' | sed 's/[][]//g')

# checks for the malicious ipv4 and prints if it is.
for ip in $IP_TO_CHECK; do
    check_ip_malicious "${api_key}" ${ip}
done

# checks for the malicious ipv6 and prints if it is.
for ip in $IPV6_TO_CHECK; do
    check_ip_malicious "${api_key}" ${ip}
done
