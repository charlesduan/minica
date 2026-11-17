#
# Configuration variables for minica. Copy this file to "filenames.sh" and edit
# as appropriate.
#

#
# Suffix for domain names
#
DOMAIN_SUFFIX=".home.arpa"

#
# Contains parameters for the certificates and requests. You may need to edit
# this file, particularly if your home domain is not .home.arpa
#
CA_CONFIG_FILE="./ca-config.cnf"

#
# Directory where files to export will be placed. It is recommended that this be
# a symlink to an external location.
#
EXPORT_DIR="export"

#
# Prefix for CA key filenames.
#
CA_KEY_PREFIX="home-network"

#
# File names for CA keys
#
ROOT_PRIVATE_KEY="ca/$CA_KEY_PREFIX-root-private.key"
ROOT_CERTIFICATE="ca/$CA_KEY_PREFIX-root-cert.crt"

IM_PRIVATE_KEY="ca/$CA_KEY_PREFIX-im-private.key"
IM_CERTIFICATE="ca/$CA_KEY_PREFIX-im-cert.crt"

#
# File names for certificate logs
#
CERT_LOG="ca/certs-issued.log"
CERTS="ca/certs"

#
# The openssl program
#
OPENSSL=openssl

#
# Ensure that the CA directory exists. This assumes that the directory used
# throughout above is "ca".
#
if ! [ -d "ca" ] ; then
    mkdir "ca" || exit 1
fi


