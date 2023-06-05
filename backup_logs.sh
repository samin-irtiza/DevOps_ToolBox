#!/bin/bash

backup_dir="$HOME/log_backup"

if [ ! -d "$backup_dir" ]; then
	mkdir "$backup_dir"
fi
	

backup_logs() {
  for log_file in "$@"
  do
    if [ -f "$log_file" ]; then
      echo "Backing up log file at $log_file"
      tar -zcvpf "$backup_dir/$(basename "$log_file")-$(date +%Y-%m-%d).tar.gz" "$log_file"
    else
      echo "Log file at $log_file not found"
    fi
  done
}

setup_cron() {
  script_path=$(realpath "\$0")
  cron_schedule="0 0 * * *"
  
  if ! (crontab -l | grep -q "$script_path"); then
    echo "Setting up cron job for log backup"
    (crontab -l 2>/dev/null; echo "$cron_schedule $script_path") | crontab -
  else
    echo "Cron job already exists"
  fi
}

if [ "$1" == "--setup-cron" ]; then
  setup_cron
else
  backup_logs "$@"
fi

