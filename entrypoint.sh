#!/bin/sh
set -eu

# Health listener should not depend on secrets
cp /etc/nginx/health.conf.template /etc/nginx/conf.d/00-health.conf

# If secrets aren't set, still start nginx so health works (and egress blocks just won't include header)
if [ -z "${SECRET_HEADER_NAME:-}" ] || [ -z "${SECRET_HEADER_VALUE:-}" ]; then
  echo "WARN: SECRET_HEADER_NAME/VALUE not set; starting with health only" >&2
  nginx -t
  exec nginx -g "daemon off;"
fi

export SECRET_HEADER_NAME SECRET_HEADER_VALUE

# ... generate egress.conf as you already do ...


# 2) Egress listener blocks
OUT="/etc/nginx/conf.d/egress.conf"
: > "$OUT"

gen_region () {
  region_prefix="$1"
  base_port="$2"

  i=1
  while [ $i -le 10 ]; do
    export PORT=$((base_port + i))
    export SLOT_HOST="${region_prefix}-${i}.adysis.com"

    envsubst '${PORT} ${SLOT_HOST} ${SECRET_HEADER_NAME} ${SECRET_HEADER_VALUE}' \
      < /etc/nginx/nginx.conf.template >> "$OUT"
    printf "\n" >> "$OUT"

    i=$((i + 1))
  done
}

gen_region "pbc-northamerica" 16000
gen_region "pbc-southamerica" 17000
gen_region "pbc-europe"       18000
gen_region "pbc-africa"       19000
gen_region "pbc-middleeast"   20000
gen_region "pbc-asia"         21000
gen_region "pbc-oceania"      22000

nginx -t
exec nginx -g "daemon off;"

