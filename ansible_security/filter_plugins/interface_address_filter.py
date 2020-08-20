from jinja2.filters import contextfilter
from ansible.errors import AnsibleFilterError


@contextfilter
def interface_address(context, interface, ip_version='4', *args, **kwargs):
    address = None

    vars_ = context.get('vars')
    interfaces = vars_['ansible_interfaces']

    if interface not in interfaces:
        raise AnsibleFilterError("Can not found interface: %s" % interface)

    if str(ip_version) == '4':
        address = vars_['ansible_' + interface]['ipv4']['address']
    elif str(ip_version) == '6':
        addresses = vars_['ansible_'+interface]['ipv6']
        global_addresses = [address for address in addresses
                            if address['scope'] == 'global'
                            and address['prefix'] != '128']
        if global_addresses:
            address = global_addresses[0]['address']
    else:
        raise AnsibleFilterError('Unknow ip_version parameter: %s' %
                                 ip_version)
    if not address:
        raise AnsibleFilterError(
            "Can not found ipv%s address for interface: %s" %
            (ip_version, interface))

    return address


class FilterModule(object):
    def filters(self):
        return {
            'address': interface_address
        }
