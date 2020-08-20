# Basic Usage

## use flat network mapping

```
# ansible inventory file
[all:vars]
os_net_config_yaml=env/3nics/network_flat.yml
```

run playbooks

```
ansible-playbook -i hosts config
```

# Network Mapping Advanaced

## use different node id for public

```yaml
# /etc/ict/globals.yml
public_subnet: "192.168.100.0/23"
public_address: "{{ public_subnet|ipmath=(node_public_id) }}"
```

```
# ansible inventory file
[control]
control1 node_id=10 node_public_id=100
control2 node_id=11 node_public_id=127
```

## use random address for public

```
# ansible inventory file
[control]
control1 node_id=10 public_address=192.168.100.33
control1 node_id=10 public_address=192.168.100.199
```

## custom tenant network mtu

```
# /etc/ict/globals.yml
storage_mtu: 9000
storagemgmt_mtu: 9000
tenant_mtu: 4000
```
