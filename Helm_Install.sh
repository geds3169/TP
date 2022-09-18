#!/bin/bash
################################################
#
# title: K8S  StorageClass Installation
# 
# What it do:
# 
# This script install helm,
# Install a longhorn StorageClass using helm,
# Create namespace longhorn-system.
#
# Date: Sept 2022
# Autors: Guilhem SCHLOSSER
#         Christophe Garcia
#		  Antoine Leomant
# Script name: Helm_Install.sh
#
# Usage: sudo bash ./Helm_Install.sh
#
#
# Tested: Centos7
################################################
# PID Shell script
echo "PID of this script: $$"
#Name of script
echo "The name of the script is : $0"

# Prevent execution: test Os & Print information system
if [ -f /etc/redhat-release ] ; then
	cat /etc/redhat-release
else
	echo "Distribution is not supported"
	exit 1
fi

title= "K8S  StorageClass Installation"
echo -e "\n\n${title}\n\n"

echo -e "Add repository helm and install\n"
# Add helm repository to the system
sudo bash -c "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && bash ./get_helm.sh && rm -f ./get_helm.sh"

echo -e "\n\nupdate repository helm before using\n"
# Update repository
helm repo update

echo -e "\n\nInstall longhorn StorageClass using helm"
echo -e "This part can take a few minutes '(+/-4m)' depending on the performance of the machine\n"
# Install jq iscsi-initiator-utils and add repo longhorn.io use helm
sudo yum -y install jq iscsi-initiator-utils 
bash -c "/usr/local/bin/helm repo add longhorn https://charts.longhorn.io/ && kubectl create namespace longhorn-system && /usr/local/bin/helm repo update && /usr/local/bin/helm install longhorn longhorn/longhorn --namespace longhorn-system"


