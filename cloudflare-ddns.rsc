# Cloudflare DDNS script r1.2 for RouterOS v7
# by klayf <contact@klayf.com>

:if ($bound=1) do={

  ######## Please edit below ########

  :local cfAccount      "your@cloudflare-account.com"
  :local cfDomainName   "yourdomain.com"
  :local cfDNSZoneId    "your_API_Zone_ID"
  :local cfAPIToken     "your_API_Token"

  ###################################

  :local wanAddr $"lease-address"
  :local rcType  "A"
  :if ([:len ([:toip6 $wanAddr])] > 0) do={:set rcType "AAAA"}
  :delay 1s;

  :local cfGetURL    "https://api.cloudflare.com/client/v4/zones/$cfDNSZoneId/dns_records?type=$rcType&name=$cfDomainName"
  :local cfGetHeader "Authorization: Bearer $cfAPIToken, Content-Type: application/json"
  :local cfDNSGet    ([/tool fetch mode=https http-method=get output=user http-header-field=$cfGetHeader url=$cfGetURL as-value]->"data")

  :if ([:len $cfDNSGet] != 0) do={
      :local cfDNSRecordId ([:deserialize from=json value=([:pick $cfDNSGet 11 ([:len $cfDNSGet]-1)])]->"id")
      :local cfDNSTtl      ([:deserialize from=json value=([:pick $cfDNSGet 11 ([:len $cfDNSGet]-1)])]->"ttl")
      :local cfDNSProxied  ([:deserialize from=json value=([:pick $cfDNSGet 11 ([:len $cfDNSGet]-1)])]->"proxied")
      :local cfPrevAddr    ([:deserialize from=json value=([:pick $cfDNSGet 11 ([:len $cfDNSGet]-1)])]->"content")

      :if ($cfPrevAddr = $wanAddr) do={
          :log info "[Cloudflare DDNS] current address is already registered and will not be updated (code: 10)";
      } else={
          :local cfUpdateURL    "https://api.cloudflare.com/client/v4/zones/$cfDNSZoneId/dns_records/$cfDNSRecordId"
          :local cfUpdateHeader "X-Auth-Email: $cfAccount, Authorization: Bearer $cfAPIToken, Content-Type: application/json"
          :local cfUpdateData   "{\"type\":\"$rcType\",\"name\":\"$cfDomainName\",\"content\":\"$wanAddr\",\"ttl\":$cfDNSTtl,\"proxied\":$cfDNSProxied}"
          :local cfDNSUpdate    [/tool fetch mode=https http-method=put output=user http-header-field=$cfUpdateHeader http-data=$cfUpdateData url=$cfUpdateURL as-value]
          :log info "[Cloudflare DDNS] dns record updated! [ $cfPrevAddr -> $wanAddr ] (code: 11)"
      }
  } else={
      :log error "[Cloudflare DDNS] domain credentials are incorrect or the server cannot be accessed (code: -13)";
  }
} else={
  :log warning "[Cloudflare DDNS] DHCP Client detected a change, waiting for an address lease (code: -10)"
}
