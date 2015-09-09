#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
dumpbin /linkermember libevent.lib /out:linkermember.txt
"""

import os, string, sys, subprocess

ls_map = {}
with open('linkermember.txt', 'r') as f:
    for line in f:
        sa = line.split()
        if (len(sa) == 2 and sa[1][0] == '_' and sa[1][1] in string.lowercase and sa[1][-1] in string.lowercase + string.digits):
            if (sa[1][1:] not in ls_map):
                #print sa[1][1:]
                ls_map[sa[1][1:]] = 1

print "got %s symbos" % len(ls_map)

es_map = {}
for ls in ls_map:    
        # grep -r "[^0-9a-z]event_new[^0-9a-z]" *.h
        p = subprocess.Popen(['grep', '-r', '[^0-9a-z]%s[^0-9a-z]' % ls, '*.h'], stdout=subprocess.PIPE)
        r = p.communicate()
        if (p.returncode == 0 and r[0] and len(r[0].strip()) >= len(ls)):
            if (ls not in es_map):
                es_map[ls] = 1

print "got %s exports" % len(es_map)

es_array = es_map.keys()
es_array.sort()
with open('libevent.def', 'w') as f:
    f.write('EXPORTS\n');
    for es in es_array:
        f.write(es)
        f.write('\n')
