source ~/devcloud_admin_cred.sh
export env_http_proxy=http://10.135.121.138:3128/
export env_https_proxy=http://10.135.121.138:3128/
# only for mac
#export CFLAGS="-I/usr/local/opt/libffi/lib/libffi-3.0.13/include/"
# this is also only required on mac
# export timeout_command=gtimeout
export consul_discovery_token=$(curl http://consuldiscovery.linux2go.dk/new)
export BUILD_NUMBER=`date +"%d%m%y%H%M%S"`
export env=at
# you need to create one of these
export cloud_provider=devcloud
export KEY_NAME=vignesh
export env_file=~/devcloud_admin_cred.sh
export ssh_user=ubuntu
export git_protocol=https
#export puppet_modules_source_repo=https://github.com/bodepd/puppet-rjil
#export puppet_modules_source_branch=test_proxy
#export python_jiocloud_source_repo=git+https://github.com/bodepd/python-jiocloud
#export python_jiocloud_source_branch=deprecate_etcd
bash -x build_scripts/deploy.sh

