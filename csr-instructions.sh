#!/bin/sh
#
# Provides instructions for generating a private key and CSR.
#

. "./filenames.sh"

if [ "" = "$3" ] ; then
    echo "Usage: $0 [private-key] [domain] [csr-file]"
    echo "Default values will be used in the generated commands."
    PRIVATE_KEY="private.key"
    DOMAIN="*.host$DOMAIN_SUFFIX"
    CSR_FILE="request.csr"
else
    PRIVATE_KEY="$1"
    DOMAIN="*.$2$DOMAIN_SUFFIX"
    CSR_FILE="$3"
fi

echo
echo "Enter the following commands on the host computer:"
echo

echo "    openssl genrsa -out $PRIVATE_KEY 4096"
echo "    openssl req -new -key $PRIVATE_KEY -subj /CN=none/ \\"
echo "        -addext \"subjectAltName=DNS:$DOMAIN\" -out $CSR_FILE"

echo

echo "Then bring the CSR file to this computer."
echo
