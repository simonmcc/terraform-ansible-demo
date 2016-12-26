#!/bin/bash -e
#
# tf-deploy.sh - wrapper around terraform
#
# * ensure terraform remote is configured correctly
# * ensure run terraform remote pull
#
# https://charity.wtf/2016/03/30/terraform-vpc-and-why-you-want-a-tfstate-file-per-env/
#
# Simon McCartney (simon.mccartney@hpe.com)
#

THISSCRIPT=${BASH_SOURCE[0]:-$0}

# default verbosity level
VERBOSE=0

# default to just seeing what needs to change
TF_ACTION=plan

# load the deploy key so we have access to beanstalk for private repo
ssh_wrapper()
{
  if [ ${BASE} -ne 1 ]
  then
    # wrap the command in an agent so that we don't pause for ssh auth
    # only works with phraseless keys (you can use hpes-credentials to load
    # a passphrase for a password protected key - which you should!)
    SSH_CMD="ssh-add ${SSH_KEY} ; $*"
    echo "${SSH_CMD}" | ssh-agent bash -
  else
    echo "$*" | bash
  fi
}

log ()
{
  if [ ! -z "$_system_type" -a "$_system_type" != 'Darwin' ]; then
    # 2016-01-28 09:31:54+00:00
    echo "$(date --rfc-3339=s) ${THISSCRIPT} $*"
  else
    echo $(date +"%Y-%m-%dT %H:%M:%S%z") ${THISSCRIPT} "$*"
  fi
}

# Check that the required environment variables are set before we can continue
check_environment_is_set()
{
    DO_ERROR=0
    log "Checking correct Terraform Environment Variables are set:"
    [ -z "$TF_ENVIRONMENT" ] && { log "Need to set TF_ENVIRONMENT"; DO_ERROR=1; }
    [ -z "$TF_SWIFT_BUCKET" ] && { log "Need to set TF_SWIFT_BUCKET"; DO_ERROR=1; }
    [ -z "$TF_BACKEND_KEY" ] && { log "Need to set TF_BACKEND_KEY"; DO_ERROR=1; }
    [ -z "$TF_VAR_FILE" ] && { log "Need to set TF_VAR_FILE"; DO_ERROR=1; }
    if [ $DO_ERROR = 1 ] ; then
       log "The above Environment Variables are not set."
       log "Please ensure you are using the correct credentials or set these"
       log "variables explicity."
       log "ERROR: EXITING - Can not continue."
       exit 2
    fi
    log "TF_ENVIRONMENT: ${TF_ENVIRONMENT}"
    log "TF_BACKEND_KEY: ${TF_BACKEND_KEY}"
    log "TF_SWIFT_BUCKET: ${TF_SWIFT_BUCKET}"
    log "TF_VAR_FILE: ${TF_VAR_FILE}"
}

set_environment()
{
    # find the deploy-kit directory based on ${THISSCRIPT}
    DEPLOY_KIT="$( cd "$( dirname "${THISSCRIPT}" )" && pwd )"

    # drop the config in place, but first find it
    if [ ! -d ${DEPLOY_KIT} ] ; then
      echo "ERROR: Couldn't find deploy-kit!"
      exit 2
    fi
}

check_ssh_key()
{
  SSH_KEYS="$(ssh-add -L)"
  if [ "${SSH_KEYS/$SSH_KEY_PARTIAL}" = "${SSH_KEYS}" ]; then
    log SSH_KEYS CHECK FAILED
    exit 2
  else
    log SSH_KEYS OK
  fi
}

flush_tf_state()
{
   if [ -d "${DEPLOY_KIT}/.terraform" ]; then
     rm -rf ${DEPLOY_KIT}/.terraform
   fi
}

setup_tf_remote()
{
  (cd ${DEPLOY_KIT} ; terraform remote config -backend=swift -backend-config="path=${TF_SWIFT_BUCKET}")
}

show_help() {
cat << EOF
Usage: ${0##*/} [-hv] [-a plan|apply|destroy] [-e environment-name]

    -a          terraform action, defaults to plan
    -h          show this help message
    -e          environment to stand up, defaults to ${TF_ENVIRONMENT}
    -v          verbose mode. Can be used multiple times for increased
                verbosity
EOF
}

##
## Main
##
log Starting $0
OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
while getopts "a:e:hv" opt; do
    case "$opt" in
        a)  TF_ACTION=${OPTARG}
            ;;
        e)  TF_ENVIRONMENT=${OPTARG}
            ;;
        h)
            show_help
            exit 0
            ;;
        v)  VERBOSE=$((VERBOSE+1))
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

check_environment_is_set
set_environment
flush_tf_state
setup_tf_remote

(cd ${DEPLOY_KIT} ; terraform ${TF_ACTION} -var-file=${TF_VAR_FILE})
(cd ${DEPLOY_KIT} ; terraform remote push)

log $0 finished!
