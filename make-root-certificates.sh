#!/bin/sh

. "./filenames.sh"

########################################################################
#
# ROOT KEY
#
########################################################################

# Generate the private key
if [ -f $ROOT_PRIVATE_KEY ] ; then
    echo
    echo "Root private key file $ROOT_PRIVATE_KEY exists; not overwriting."
else
    echo
    echo "Generating private key file $ROOT_PRIVATE_KEY..."
    $OPENSSL genrsa -out $ROOT_PRIVATE_KEY 4096
    echo "Done."
fi

# Generate a self-signed certificate (-x509 -new) based on the private key.
echo
echo "Generating self-signed root certificate $ROOT_CERTIFICATE..."
$OPENSSL req -x509 -new \
    -key "$ROOT_PRIVATE_KEY" -sha256 -days 36500 \
    -config "$CA_CONFIG_FILE" -section "root_cert" \
    -out "$ROOT_CERTIFICATE"

echo "Done. Inspect with 'openssl x509 -in $ROOT_CERTIFICATE -text -noout'"




########################################################################
#
# INTERMEDIATE KEY
#
########################################################################


# Generate the intermediate key
if [ -f "$IM_PRIVATE_KEY" ] ; then
    echo
    echo "Root private key file $IM_PRIVATE_KEY exists; not overwriting."
else
    echo
    echo "Generating private key file $IM_PRIVATE_KEY..."
    $OPENSSL genrsa -out "$IM_PRIVATE_KEY" 4096
    echo "Done."
fi

echo
echo "Generating intermediate certificate $IM_CERTIFICATE..."
$OPENSSL req -x509 -new \
    -CA "$ROOT_CERTIFICATE" -CAkey "$ROOT_PRIVATE_KEY" \
    -key "$IM_PRIVATE_KEY" -sha256 -days 36500 \
    -config "$CA_CONFIG_FILE" -section "intermediate_cert" \
    -out "$IM_CERTIFICATE"
echo "Done. Inspect with 'openssl x509 -in $IM_CERTIFICATE -text -noout'"

echo
echo "Verifying intermediate key..."
$OPENSSL verify -trusted "$ROOT_CERTIFICATE" "$IM_CERTIFICATE"

