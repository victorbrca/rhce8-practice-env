#!/bin/bash

echo -e "
 ███████   ████████ ███████    ███████
░██░░░░██ ░██░░░░░ ░██░░░░██  ██░░░░░██
░██   ░██ ░██      ░██   ░██ ██     ░░██
░███████  ░███████ ░███████ ░██      ░██
░██░░░██  ░██░░░░  ░██░░░░  ░██      ░██
░██  ░░██ ░██      ░██      ░░██     ██
░██   ░░██░████████░██       ░░███████
░░     ░░ ░░░░░░░░ ░░         ░░░░░░░

You are logged into \"$(hostname)\" as the \"$(whoami)\" account.
This system is running $(cat /etc/redhat-release)

Two Repos are available on this machine:
http://repo.ansi.example.com/BaseOS
http://repo.ansi.example.com/AppStream"