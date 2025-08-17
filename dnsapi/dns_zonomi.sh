#!/usr/bin/env sh
# ~/.acme.sh/dnsapi/dns_zonomi.sh
# shellcheck disable=SC2034

dns_zonomi_info='zonomi.com
Site: zonomi.com
Docs: github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_zonomi
Options:
 ZM_Key API Key
'

: "${LE_WORKING_DIR:=$HOME/.acme.sh}"

RZ_PROVIDER="zonomi"
RZ_KEY_VAR="ZM_Key"
RZ_API="https://zonomi.com/app/dns/dyndns.jsp"

. "$LE_WORKING_DIR/dnsapi/lib/dns_rz_common.sh"

dns_zonomi_add() { rz_add "$@"; }
dns_zonomi_rm()  { rz_rm  "$@"; }
