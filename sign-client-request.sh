#!/bin/sh

#
# Given a Certificate Signing Request (CSR), checks that it is for the proper
# domain and creates a signed certificate. The usage is:
#
# ./sign-client-request.sh [CSR]
#

. "./filenames.sh"

#
# Initial tests
#
touch "$CERT_LOG"
if ! [ -f "$CERT_LOG" -a -w "$CERT_LOG" ] ; then
    echo "Log file $CERT_LOG not writable"
    exit 1;
fi
if ! [ -d "$EXPORT_DIR" ] ; then
    echo "No export dir $EXPORT_DIR"
    exit 1;
fi

DATE="`date -Iminutes`"

#
# Read the CSR filename
#
CSR_FILE="$1"
if ! [ -f "$CSR_FILE" ] ; then
    echo "Usage: $0 [csr-file]"
    exit 1
fi

DOMAINS="`openssl req -in "$CSR_FILE" -noout -text | grep DNS: | sed 's/ //g'`"

if [ "" = "$DOMAINS" ] ; then
    echo "No domains found in CSR"
    exit 1
fi

echo "Domains are $DOMAINS"

if echo "$DOMAINS" | sed 's/^DNS://;s/,DNS:/\n/g' | \
    grep -q -v "$DOMAIN_SUFFIX\$" ; then
    echo "CSR contains an invalid domain"
    exit 1
fi

CERT_PREFIX="`basename "$CSR_FILE" .csr`"
CERTIFICATE="$CERTS/`date +%s`-$CERT_PREFIX.crt"
mkdir -p "$CERTS"

echo "Generating certificate $CERTIFICATE..."
$OPENSSL req -x509 -in "$CSR_FILE" \
    -days 36500 \
    -CA "$IM_CERTIFICATE" -CAkey "$IM_PRIVATE_KEY" \
    -config "$CA_CONFIG_FILE" -section "client_cert" \
    -addext "subjectAltName=$DOMAINS" \
    -out "$CERTIFICATE"

echo "Appending intermediate and root certificates..."
cat "$IM_CERTIFICATE" "$ROOT_CERTIFICATE" >> "$CERTIFICATE"

echo "Verifying..."
$OPENSSL verify -trusted "$ROOT_CERTIFICATE" -untrusted "$IM_CERTIFICATE" \
    "$CERTIFICATE"

echo "Saving to log..."
echo "$DATE - signed certificate $CERTIFICATE for $DOMAIN" >> "$CERT_LOG"

echo "Exporting..."
EXPORT_CERT="$EXPORT_DIR/$CERT_PREFIX.crt"
cp "$CERTIFICATE" "$EXPORT_CERT"

echo "Done. Inspect with 'openssl x509 -in $EXPORT_CERT -text -noout'"
