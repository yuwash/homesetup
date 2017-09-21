#! /usr/bin/env python
import sys


def hostname_reverse(hostname, offset=0):
    '''
    :param int offset: limit to this many lower-level domains if
        positive, or omit so many higher-level domains if negative,
        or not omitting any by default for 0
    '''
    domains = hostname.split('.')
    if offset != 0:
        domains = domains[:offset]
    return '.'.join(filter(lambda s: len(s) > 0, reversed(domains)))


def repo_group_name(remote):
    if remote[:6] == 'https:':
        splitpos = remote.index('/', 8)
        host = hostname_reverse(remote[8:splitpos], -1)
    elif remote[:4] == 'git@':
        splitpos = remote.index(':', 4)
        host = hostname_reverse(remote[4:splitpos], -1)
    else:
        splitpos = remote.index(':')
        host = remote[:splitpos]
    ownername = remote[splitpos+1:remote.index('/', splitpos+1)]
    return host + '-' + ownername


def repo_name(remote):
    name = remote[remote.rindex('/')+1:]
    if name[-4:] == '.git':
        return name[:-4]
    else:
        return name


if __name__ == '__main__':
    if sys.argv[1] == '-N':
        print(repo_name(' '.join(sys.argv[2:]).strip()))
    else:
        print(repo_group_name(' '.join(sys.argv[1:]).strip()))
