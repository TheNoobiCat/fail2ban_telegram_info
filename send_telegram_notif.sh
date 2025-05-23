#!/bin/bash
# Version 1.0
# Send Fail2ban notifications using a Telegram Bot

# Add to the /etc/fail2ban/jail.conf:
# [sshd]
# ***
# action  = iptables[name=SSH, port=22, protocol=tcp]
#                       telegram

# Create a new file in /etc/fail2ban/action.d with the following information:
# [Definition]
# actionstart = /etc/fail2ban/scripts/send_telegram_notif.sh -a start
# actionstop = /etc/fail2ban/scripts/send_telegram_notif.sh -a stop
# actioncheck =
# actionban = /etc/fail2ban/scripts/send_telegram_notif.sh -n <name> -b <ip>
# actionunban = /etc/fail2ban/scripts/send_telegram_notif.sh -n <name> -u <ip>
#
# [Init]
# init = 123

# Telegram BOT Token
telegramBotToken='YOUR_BOT_TOKEN'

# Telegram Chat ID
telegramChatID='YOUR_CHAT_ID'

# IP Info API Key
ipinfoToken='YOUR_API_KEY'

function talkToBot() {
        message=$1
        curl -s -X POST https://api.telegram.org/bot${telegramBotToken}/sendMessage -d text="${message}" -d chat_id=${telegramChatID} > /dev/null 2>&1
}

if [ $# -eq 0 ]; then
        echo "Usage $0 -a ( start || stop ) || -b \$IP || -u \$IP"
        exit 1;
fi

while getopts "a:n:b:u:" opt; do
        case "$opt" in
                a)
                        action=$OPTARG
                ;;
                n)
                        jail_name=$OPTARG
                ;;
                b)
                        ban=y
                        ip_add_ban=$OPTARG
                ;;
                u)
                        unban=y
                        ip_add_unban=$OPTARG
                ;;
                \?)
                        echo "Invalid option. -$OPTARG"
                        exit 1
                ;;
        esac
done

if [[ ! -z ${action} ]]; then
        case "${action}" in
                start)
                        talkToBot "Fail2ban has been started"
                ;;
                stop)
                        talkToBot "Fail2ban has been stopped"
                ;;
                *)
                        echo "Incorrect option"
                        exit 1;
                ;;
        esac
elif [[ ${ban} == "y" ]]; then
    # Fetch info from ipinfo.io using jq to parse JSON
    ip_info=$(curl -s "https://ipinfo.io/${ip_add_ban}?token=${ipinfoToken}")
    country=$(echo "$ip_info" | jq -r '.country // "Unknown"')
    isp=$(echo "$ip_info" | jq -r '.org // "Unknown"')

    message="[${jail_name}] The IP: ${ip_add_ban} has been banned. The IP is owned by ${isp}. Country/region: ${country}"
    talkToBot "$message"
    echo "$(date): ${ip_add_ban} banned from [${jail_name}] — ${country}, ${isp}" >> /var/log/fail2ban_ipinfo.log
    exit 0;
elif [[ ${unban} == "y" ]]; then
        talkToBot "[${jail_name}] The IP: ${ip_add_unban} has been unbanned"
        exit 0;
else
        info
fi
