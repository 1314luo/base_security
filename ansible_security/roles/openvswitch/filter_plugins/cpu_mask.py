from jinja2.filters import contextfilter
from ansible.errors import AnsibleFilterError


def cpu_mask(cpus):
    if cpus.startswith('0x'):
        return cpus

    cpu_list = []
    if ',' in cpus:
        cpu_list = cpus.split(',')
    elif ' ' in cpus:
        cpu_list = cpus.split(' ')
    else:
        cpu_list = [cpus]

    try:
        current = 0
        for i in cpu_list:
            current = current | 1 << int(i)
        return hex(current)
    except Exception as e:
        raise AnsibleFilterError("to mask error:  %s" % str(e))


class FilterModule(object):
    def filters(self):
        return {
            'cpu_mask': cpu_mask
        }
