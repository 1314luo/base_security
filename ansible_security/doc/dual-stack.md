# use dual stack for all plane

globals.yml file

```yaml
---
control_subnet:
  - 192.168.1.0/24
  - fc00:1::/64
control_vlan: 124
control_gateway:
  - 192.168.1.1
  - fc00:1::1

public_subnet:
  - 192.168.2.0/24
  - fc00:2::/64
public_vlan: 125

internal_subnet:
  - 192.168.3.0/24
  - fc00:3::/64
internal_vlan: 126

admin_subnet:
  - 192.168.4.0/24
  - fc00:4::/64
admin_vlan: 127

storage_subnet:
  - 192.168.5.0/24
  - fc00:5::/64

storagemgmt_subnet:
  - 192.168.6.0/24
  - fc00:6::/64
```

```
ansible-playbook ... \
    -e @env/dualstack.yml
```
