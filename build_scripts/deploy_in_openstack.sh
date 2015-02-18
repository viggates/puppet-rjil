#!/bin/bash -x

# Validate the existance of local.conf and source it
localrc="local.conf"
if [ -f "$localrc" ]
then
    source local.conf
else
    echo "Create local.conf before executing this script."
fi

# export proxies
export env_http_proxy=$http_proxy
export env_https_proxy=$https_proxy

# Generate build number
export RANDOM=`date +"%d%m%y%H%M%S"`
export BUILD_NUMBER=${BUILD_NUMBER:-$RANDOM}
export env=at


# Generate openrc
cat << EOF > openrc
export OS_AUTH_URL="$OS_AUTH_URL"
export OS_TENANT_ID=$OS_TENANT_ID
export OS_TENANT_NAME=$OS_TENANT_NAME
export OS_USERNAME=$OS_USERNAME
export OS_PASSWORD=$OS_PASSWORD
export OS_REGION_NAME=$OS_REGION_NAME
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
EOF

export env_file=openrc

echo $cloud_provider | grep "hp\|jio_staging"
if [ $? -eq 1 ];
then
# Create cloud_provider yaml
cat << EOF > hiera/data/cloud_provider/${cloud_provider}.yaml
public_address: "%{ipaddress_eth0}"
public_interface: ${PUBLIC_INTERFACE:-eth0}
private_address: "%{ipaddress_vhost0_or_eth0}"
private_interface: ${PUBLIC_INTERFACE:-eth0}

rjil::system::proxies:
  "no":
    url: "127.0.0.1,169.254.169.254,localhost,consul,jiocloud.com"
  http:
    url: "$env_http_proxy"
  https:
    url: "$env_https_proxy"

rjil::system::ntp::run_ntpdate: false
EOF

# Generate custom user data
cat  << EOF_MAIN >> custom_user_data
cat << EOF > /tmp/rjil/hiera/data/cloud_provider/${cloud_provider}.yaml
`cat hiera/data/cloud_provider/${cloud_provider}.yaml`
EOF
EOF_MAIN

# Create cloud_provider map yaml
cat << EOF > environment/${cloud_provider}.map.yaml
image:
  trusty: $OS_IMAGE_ID
flavor:
  small: $OS_FLAVOR_SMALL_ID
  medium: $OS_FLAVOR_MEDIUM_ID
  large: $OS_FLAVOR_LARGE_ID
  storage: $OS_FLAVOR_STORAGE_ID
networks:
  default:
     - $OS_NETWORKS_DEFAULT_ID
EOF
fi

# Deploy
bash -x build_scripts/deploy.sh




