#!/bin/sh

#
# Constructs a public/private key and signed certificate for a domain. The usage
# is:
#
# ./make-client-cert.sh [PREFIX] [DOMAIN...]
. "./filenames.sh"

#
# Test that the log is writable
#
touch "$CERT_LOG"
if ! [ -f "$CERT_LOG" -a -w "$CERT_LOG" ] ; then
    echo "Log file $CERT_LOG not writable"
    exit 1;
fi

#
# Read the file prefix
#
PREFIX="$1"
if [ 'x' = "x$PREFIX" ] ; then
    echo "Usage: $0 [file-prefix] [domain-prefix...]"
    exit 1
fi

shift

#
# Compute the domain names
#
DOMAIN=""
while [ '' != "$1" ] ; do
    if echo "$1" | grep -q '[:,]' ; then
        echo "Invalid domain name character found in $1; exiting"
        exit 1
    fi

    #
    # Append "DNS:" entry to $DOMAIN as a comma-separated list
    #
    if [ '' = "$DOMAIN" ] ; then
        DOMAIN="DNS:$1$DOMAIN_SUFFIX"
    else
        DOMAIN="$DOMAIN,DNS:$1$DOMAIN_SUFFIX"
    fi
    shift
done

#
# Check that at least one domain is present
#
if [ '' = "$DOMAIN" ] ; then
    echo "Usage: $0 [file-prefix] [domain-prefix...]"
    exit 1
fi
echo "Certificate domain is $DOMAIN"

PRIVATE_KEY="$PREFIX-private.key"
CERTIFICATE="$PREFIX-cert.crt"
DATE="`date -Iminutes`"

########################################################################
#
# CLIENT KEY
#
########################################################################

#
# Generate the private key
#
if [ -f "$PRIVATE_KEY" ] ; then
    echo
    echo "Private key file $PRIVATE_KEY exists; not overwriting."
else
    echo
    echo "Generating private key file $PRIVATE_KEY..."
    openssl genrsa -out $PRIVATE_KEY 4096
    echo "Done."
fi
echo "$DATE - created private key $PRIVATE_KEY" >> "$CERT_LOG"

echo
echo "Generating certificate $CERTIFICATE..."
$OPENSSL req -x509 -new \
    -key "$PRIVATE_KEY" -sha256 -days 36500 \
    -CA "$IM_CERTIFICATE" -CAkey "$IM_PRIVATE_KEY" \
    -config "$CA_CONFIG_FILE" -section "client_cert" \
    -addext "subjectAltName=$DOMAIN" \
    -out "$CERTIFICATE"
echo "Appending intermediate and root certificates..."
cat "$IM_CERTIFICATE" "$ROOT_CERTIFICATE" >> "$CERTIFICATE"

echo "Verifying..."
$OPENSSL verify -trusted "$ROOT_CERTIFICATE" -untrusted "$IM_CERTIFICATE" \
    "$CERTIFICATE"

echo "Saving to log..."
mkdir -p "$CERTS"
cp "$CERTIFICATE" "$CERTS/`date +%s`-$CERTIFICATE"
echo "$DATE - wrote certificate $CERTIFICATE for $DOMAIN" >> "$CERT_LOG"

echo "Done. Inspect with 'openssl x509 -in $CERTIFICATE -text -noout'"
