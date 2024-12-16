# routeros-cloudflare-ddns
Cloudflare DDNS script for MikroTik RouterOS v7

## How does it work?


## Features
- Efficient as it runs on DHCP Client level.
- Cloudflare DNS ID is automatically retrieved, and TTL and Proxied values are preserved as existing settings.
- Supports both IPv4 and IPv6 addresses, and automatically selects DNS record type (A or AAAA) depending on the version.
- It consists of simple code, so it runs smoothly even on low-end devices. (Tested on hAP ac lite)
- Written for RouterOS v7, no external parsing script is required.

## Set required Variables
- `cfAccount` - Email address used as Cloudflare account
- `cfDomainName` - Domain(DNS Record name) to which DDNS will be applied (e.g. nas.example.com)
- `cfDNSZoneId` - DNS Zone ID of Cloudflare account (Displayed at the bottom right of your Cloudflare Dashboard)
- `cfAPIToken` - API token of Cloudflare account (It can be created from the bottom right of the Cloudflare Dashboard)

## Applying scripts to RouterOS
