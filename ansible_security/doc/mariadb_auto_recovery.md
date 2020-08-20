# Deploy mariadbops

run playbooks

```
ansible-playbook -i /etc/ansible/hosts mariadb_auto_recovery.yml -e action=deploy
```

# Destroy mariadbops

run playbooks

```
ansible-playbook -i /etc/ansible/hosts mariadb_auto_recovery.yml -e action=destroy
```
