#!/bin/sh

. "./filenames.sh"

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
while [ 'x' != "x$1" ] ; do
    if echo "$1" | grep -q '[:,]' ; then
        echo "Invalid domain name character found in $1; exiting"
        exit 1
    fi

    if [ 'x' = "x$DOMAIN" ] ; then
        DOMAIN="DNS:$1.home.arpa"
    else
        DOMAIN="$DOMAIN,DNS:$1.home.arpa"
    fi
    shift
done
if [ 'x' = "x$DOMAIN" ] ; then
    echo "Usage: $0 [file-prefix] [domain-prefix...]"
    exit 1
fi
echo "Certificate domain is $DOMAIN"

PRIVATE_KEY="$PREFIX-private.key"
CERTIFICATE="$PREFIX-cert.crt"

########################################################################
#
# CLIENT KEY
#
########################################################################

# Generate the private key
if [ -f "$PRIVATE_KEY" ] ; then
    echo
    echo "Private key file $PRIVATE_KEY exists; not overwriting."
else
    echo
    echo "Generating private key file $PRIVATE_KEY..."
    openssl genrsa -out $PRIVATE_KEY 4096
    echo "Done."
fi

echo
echo "Generating certificate $CERTIFICATE..."
$OPENSSL req -x509 -new \
    -key "$PRIVATE_KEY" -sha256 -days 36500 \
    -CA "$IM_CERTIFICATE" -CAkey "$IM_PRIVATE_KEY" \
    -config "$CA_CONFIG_FILE" -section "client_cert" \
    -addext "subjectAltName=$DOMAIN" \
    -out "$CERTIFICATE"
echo "Appending root and intermediate certificates..."
cat "$IM_CERTIFICATE" "$ROOT_CERTIFICATE" >> "$CERTIFICATE"

echo "Verifying..."
$OPENSSL verify -trusted "$ROOT_CERTIFICATE" -untrusted "$IM_CERTIFICATE" \
    "$CERTIFICATE"

echo "Done. Inspect with 'openssl x509 -in $CERTIFICATE -text -noout'"
