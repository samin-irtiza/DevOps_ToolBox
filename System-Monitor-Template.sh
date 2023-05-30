#!/bin/bash

# variables
alert_email="your-email@example.com"
subject="System Resource Alert"
cpu_threshold=80
memory_threshold=80
disk_usage_threshold=90
log_file="/path/to/application.log"
error_keywords="error|critical|failure"

# CPU
cpu_usage=$(top -bn1 | awk '/Cpu/ { print $2}')
if (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )); then
    message="Warning: CPU usage is at ${cpu_usage}% which is above the threshold of ${cpu_threshold}%."
    echo "$message" | mail -s "$subject" "$alert_email"
fi

# Memory
total_memory=$(free -m | awk '/Mem/{print $2}')
used_memory=$(free -m | awk '/Mem/{print $3}')
memory_usage=$(echo "scale=2; $used_memory / $total_memory * 100" | bc)
if (( $(echo "$memory_usage > $memory_threshold" | bc -l) )); then
    message="Warning: Memory usage is at ${memory_usage}% which is above the threshold of ${memory_threshold}%."
    echo "$message" | mail -s "$subject" "$alert_email"
fi

# Disk Usage
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$disk_usage" -gt "$disk_usage_threshold" ]; then
    message="Warning: Disk usage is at ${disk_usage}% which is above the threshold of ${disk_usage_threshold}%."
    echo "$message" | mail -s "$subject" "$alert_email"
fi

# app logs
errors=$(grep -Ei "$error_keywords" "$log_file")
if [ -n "$errors" ]; then
    message="Warning: The following errors were found in the application log:\n$errors"
    echo -e "$message" | mail -s "$subject" "$alert_email"
fi
