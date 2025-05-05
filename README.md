# Fail2ban Telegram Notifications

![](https://deividsdocs.files.wordpress.com/2020/04/telegram_notifications_fail2ban.jpg)

Sending **fail2ban** notifications using a **Telegram** bot, with ISP and Country information.

Forked from [deividgdt/fail2ban_telegram_notifications](https://github.com/deividgdt/fail2ban_telegram_notifications). I added country and ISP information to the telegram notifications using the free ipinfo.io API.

## Installation and configuration
- Add the following two lines, for example, to **SSHD** in the file **/etc/fail2ban/jail.conf**, make sure to tab the word **telegram**.
  
  ```sh
  action  = iptables[name=SSH, port=22, protocol=tcp]
  		telegram
  ```
  Example:
  
  ![](https://deividsdocs.files.wordpress.com/2020/04/fail2ban-sshd-conf.png)
  
- Download the file **telegram.conf** and move it to **/etc/fail2ban/action.d/**
- Download the file **send_telegram_notif.sh** move it to **/etc/fail2ban/scripts/**
- Modify the file **/etc/fail2ban/scripts/send_telegram_notif.sh** and add your **Token** your **Chat ID** and your **IPINFO.io API Key**:

  ```sh
  telegramBotToken=YOUR_BOT_TOKEN
  telegramChatID=YOUR_CHAT_ID
  ipinfoToken=YOUR_API_KEY
  ```
- Make the file executable

  ```sh
  chmod +x /etc/fail2ban/scripts/send_telegram_notif.sh
  ```
- Restart the fail2ban service and enjoy!

  ```sh
  systemctl restart fail2ban
  ```
 
## Usage
+ /etc/fail2ban/scripts/send_telegram_notif.sh -a [ start || stop ] || [ -n $NAME -b $IP || -n $NAME -u $IP ]"
  + -a (action)
  + -n (jail name)
  + -b (ban)
  + -u (unban)