import json,re,sys,glob,os,collections as C
sys.path.insert(0,'.')
S='/home/user/nhlpa93snes'
d=json.load(open('comment_plan.json'))
def split(l):
    q=None
    for i,ch in enumerate(l):
        if q:
            if ch==q:q=None
        elif ch in "'\"":q=ch
        elif ch==';':return l[:i],l[i:]
    return l,None
loc=C.Counter();locun=C.Counter();q=C.defaultdict(dict)
first=C.Counter()
for rel,fi in d['files'].items():
    lines=open(S+'/'+rel,encoding='latin-1').read().split('\n')
    cur=None
    for i,l in enumerate(lines):
        c,cm=split(l)
        m=re.match(r'^([A-Za-z_]\w*):',l)
        if m: cur=m.group(1); q[rel][cur]=dict(loc=0,locun=0,lbl=' '.join(x.strip(';').strip() for x in [cm or ''])); 
        if m:
            j=i+1
            while j<len(lines) and re.match(r'^\t{8,}\s*;',lines[j]): q[rel][cur]['lbl']+=' '+lines[j].strip().lstrip(';').strip(); j+=1
            continue
        m=re.match(r'^(\.\w+):',l)
        if m and cur:
            q[rel][cur]['loc']+=1
            if not cm: q[rel][cur]['locun']+=1
for r in d['plan']:
    x=q[r['file']].get(r['routine'],{})
    t=x.get('lbl','').lower()
    r['local_labels']=x.get('loc',0);r['local_labels_uncommented']=x.get('locun',0)
    r['label_comment_chars']=len(t)
    r['label_mentions']=[w for w,k in [('called',r'call|from |entered|used by|jumped'),('takes',r'\bd[0-7]\b|\ba[0-6]\b|takes|input|\bin:'),('returns',r'return|result|exit|sets|\bout')] if re.search(k,t)]
json.dump(d,open('comment_plan.json','w'),indent=1)
p=d['plan']
print('locals',sum(r['local_labels'] for r in p),sum(r['local_labels_uncommented'] for r in p))
print('lbl short(<25ch)',sum(r['label_comment_chars']<25 for r in p),'no call info',sum('called' not in r['label_mentions'] for r in p))
print(C.Counter(len(r['label_mentions']) for r in p))
f=d['files']
# worst files
rows=[]
for k,v in f.items():
    rr=[r for r in p if r['file']==k]
    sc=sum(r['s_comments'] for r in rr);cl=sum(r['s_lines'] for r in rr)
    gc=sum(r['g_comments'] or 0 for r in rr);gl=sum(r['g_lines'] or 0 for r in rr)
    unc=sum(r['local_labels_uncommented'] for r in rr)
    v['s_comments']=sc;v['density']=round(sc/max(cl,1),2);v['g_comments']=gc;v['g_lines']=gl;v['locun']=unc
    v['gap']=max(gc-sc,int(cl*0.4)-sc if any(r['action']=='write' for r in rr) else 0,0)
    rows.append((v['gap'],k,cl,sc,gc,gl,v['density'],unc))
rows.sort(reverse=True)
for r in rows[:20]:print(r)
json.dump(d,open('comment_plan.json','w'),indent=1)
# batch recheck using gap
for b in d['batches']:print(b['batch'],b['code_lines'],sum(f[k]['gap'] for k in b['files']))
print(C.Counter(r['density']>0.25 for r in [dict(density=v['density']) for v in f.values()]))
print(sorted(set(k.split('/')[2] for k in f)))
