import re, os, glob, json, csv, sys, collections
sys.path.insert(0,'/home/user/nhlpa93snes/tools')
import check_comments as cc
S='/home/user/nhlpa93snes'; G='/home/user/nhlpa93genesis/src'
def split(l):
    q=None
    for i,ch in enumerate(l):
        if q:
            if ch==q:q=None
        elif ch in "'\"":q=ch
        elif ch==';':return l[:i],l[i:]
    return l,None
LBL_G=re.compile(r'^([A-Za-z_][A-Za-z_0-9]*)(:?)(\s|$)')
DIR=set('include incbin if ifdef ifndef else endif endc macro endm rept endr org even dc.b dc.w dc.l ds.b ds.w ds.l equ set rs.b rs.w rs.l opt cnop section xdef xref IF ENDIF ELSE'.lower().split())
# ---- 93G routines
groutines={}  # name -> dict
glow={}
for f in sorted(glob.glob(G+'/*.asm')):
    lines=open(f,encoding='latin-1').read().split('\n')
    cur=None
    for n,l in enumerate(lines,1):
        if not l.strip(): continue
        if l[0] in ' \t':
            code,cm=split(l)
            if cur is None: continue
            if code.strip():
                cur['code']+=1
                if cm: cur['cm']+=1
            elif cm: cur['cm']+=1
            continue
        if l[0]==';':
            if cur is not None: cur['cm']+=1
            continue
        m=LBL_G.match(l)
        if not m: continue
        name=m.group(1)
        if name.lower() in DIR: continue
        rest=l[m.end(1)+len(m.group(2)):]
        code,cm=split(rest)
        w=code.split()
        if w and w[0].lower() in ('equ','=','rs.b','rs.w','rs.l','ds.b','ds.w','ds.l','set') : cur=None; continue
        if name.startswith('.'): continue
        cur=dict(name=name,file=os.path.basename(f),line=n,code=0,cm=0,lblcm=bool(cm))
        if code.strip(): cur['code']+=1
        if cm: cur['cm']+=1
        if name not in groutines: groutines[name]=cur
        glow.setdefault(name.lower(),name)
# ---- 93S routines
OTHER=re.compile(r'\b(loc_|sub_|unk_|CODE_[0-9A-F]{6})|\.asm\b|\.s\b|\b(Genesis|Mega ?Drive|NHL ?9[0-9]|NHLPA ?9[0-9]|68000|68k|Sega|SNES version|PAL)\b|\$[89A-Fa-f][0-9A-Fa-f]{5}\b|\b9[2-4]G?\b',re.I)
GAME=re.compile(r'\b(Genesis|Mega ?Drive|NHL ?9[0-9]|NHLPA ?9[0-9]|68000|Sega)\b|\b9[24]\b(?! *\w*[a-z]*\))|\b93G\b|\b92G\b')
ADDR=re.compile(r'\$[89A-Fa-f][0-9A-Fa-f]{5}\b')
IDA=re.compile(r'\b(loc_|sub_|unk_)|CODE_[0-9A-F]{6}')
SEG=re.compile(r'\b\w+93s?\.asm\b|\b\w+\.asm\b|\bbank ?\$?[0-9A-F]{2}\b|\.s\b')
def parse_s(path):
    lines=open(path,encoding='latin-1').read().split('\n')
    hdr=0; seen=False
    rs=[];cur=None
    for n,l in enumerate(lines,1):
        if not l.strip():continue
        code,cm=split(l)
        isl=l[0] not in ' \t;' 
        if isl and not code.strip().startswith('.'):
            m=re.match(r'^([A-Za-z_][A-Za-z_0-9]*):',l)
            if m and not l.startswith('.'):
                cur=dict(name=m.group(1),line=n,code=0,cm=0,lblcm=bool(cm),lblcm_lines=0,txt=[])
                rs.append(cur); seen=True
                if cm:cur['cm']+=1;cur['txt'].append(cm)
                rest=code[m.end():]
                if rest.strip():cur['code']+=1
                continue
        if not seen:
            if l.startswith(';'):hdr+=1
            continue
        if cur is None:continue
        if code.strip():
            if re.match(r'^\.?[A-Za-z_0-9]+:\s*$',code.strip()) :
                pass  # local label alone
            cur['code']+=1
            if cm:cur['cm']+=1;cur['txt'].append(cm)
        elif cm:
            cur['cm']+=1;cur['txt'].append(cm)
            # continuation of label comment
            if l.startswith('\t\t\t\t\t\t\t\t\t') and cur['code']==0 or (cur['code']<=0 and cm):
                cur['lblcm_lines']+=1
    return rs,hdr,lines
# lookup tables
extra={}  # 93S name -> 93G name from docs
for f in glob.glob(S+'/docs/history/unmatched_vs_93g*.md'):
    for l in open(f,encoding='utf-8'):
        if l.startswith('|'):
            c=[x.strip() for x in l.strip().strip('|').split('|')]
            if len(c)>=3 and re.match(r'^[A-Za-z_]\w*$',c[0]):
                g=re.match(r'^([A-Za-z_]\w*)',c[2])
                if g: extra.setdefault(c[0],[]).append(g.group(1)); 
                if c[1] and re.match(r'^[A-Za-z_]\w*$',c[1]): extra.setdefault(c[0],[]).append(c[1])
def twin(name,txt):
    for cand,how in [(name,'name')]:
        if cand in groutines:return groutines[cand],how
    if name.lower() in glow:return groutines[glow[name.lower()]],'case'
    m=re.match(r'^(.*?)(8[0-9A-F]|9[0-9A-F]|B[0-9A-F])$',name)
    if m and m.group(1) in groutines:return groutines[m.group(1)],'bankcopy'
    for c in extra.get(name,[]):
        if c in groutines:return groutines[c],'docs'
    for t in txt:
        for m in re.finditer(r'\b(?:92|93G) ([A-Za-z_]\w*)',t):
            if m.group(1) in groutines:return groutines[m.group(1)],'note'
    m=re.match(r'^(\w+?)_(\w+)$',name)
    if m and m.group(1) in groutines:return groutines[m.group(1)],'parent'
    return None,None
rows=[];files={}
for f in sorted(glob.glob(S+'/src/routines/*/*.asm')):
    rel=os.path.relpath(f,S);area=rel.split('/')[2]
    rs,hdr,lines=parse_s(f)
    viol=[(n,m) for n,m in cc.check(f)]
    body='\n'.join(lines)
    other=len(GAME.findall(''.join(c for l in lines for c in [split(l)[1] or ''])))
    addr=len(ADDR.findall(''.join(split(l)[1] or '' for l in lines)))
    ida=len(IDA.findall(''.join(split(l)[1] or '' for l in lines)))
    files[rel]=dict(area=area,header=hdr,viol=len(viol),viol_kinds=collections.Counter(re.sub(r'\d+','N',m) for n,m in viol),other=other,addr=addr,ida=ida,lines=len(lines),code=sum(r['code'] for r in rs),routines=len(rs))
    for r in rs:
        t,how=twin(r['name'],r['txt'])
        sd=r['cm']/max(r['code'],1)
        row=dict(file=rel,routine=r['name'],s_line=r['line'],g93_file=t and t['file'],g93_line=t and t['line'],s_lines=r['code'],s_comments=r['cm'],
                 g_lines=t and t['code'],g_comments=t and t['cm'],s_label_comment=r['lblcm'],twin_how=how,s_density=round(sd,2),g_density=t and round(t['cm']/max(t['code'],1),2),area=area)
        if t:
            gd=t['cm']/max(t['code'],1)
            ratio=r['code']/max(t['code'],1)
            gain=t['cm']-r['cm']
            better = gd>sd*1.25 and gain>=2 or (not r['lblcm'] and t['lblcm'])
            if better:
                act='port' if 0.5<=ratio<=2.5 else 'adapt'
            elif not r['lblcm'] or (sd<0.3 and r['code']>=6): act='adapt'
            else: act='ok'
        else:
            act='write' if (not r['lblcm'] or sd<0.35 and r['code']>=4) else 'ok'
        if r['code']<=2 and r['lblcm'] and act in('port','adapt','write'): act='ok'
        row['action']=act
        rows.append(row)
# file level
byfile=collections.defaultdict(list)
for r in rows:byfile[r['file']].append(r)
for k,fi in files.items():
    rr=byfile[k]
    pri=['write','port','adapt','ok']
    fi['actions']=collections.Counter(r['action'] for r in rr)
    fi['need']=sum(r['s_lines'] for r in rr if r['action']!='ok')
    fi['gain']=sum(max((r['g_comments'] or 0)-r['s_comments'],0) if r['g_comments'] is not None else max(int(r['s_lines']*0.5)-r['s_comments'],0) for r in rr if r['action']!='ok')
# batching: by area then greedy equal size on need+code
items=sorted(files.items())
tot=sum(v['code'] for k,v in items)
NB=12;target=tot/NB
# split big areas contiguous alphabetically, areas ordered; contiguous chunks keep areas together
batches=[];cur=[];cs=0
for k,v in items:
    cur.append(k);cs+=v['code']
    if cs>=target*(len(batches)+1)-sum(0 for _ in [])-0 and False:pass
acc=0;b=[];bi=1;order=[]
for k,v in sorted(items,key=lambda kv:(kv[1]['area'],kv[0])):
    b.append(k);acc+=v['code']
    if acc>=target*bi and len(batches)<NB-1:
        batches.append(b);b=[];bi+=1
if b:batches.append(b)
for i,b in enumerate(batches,1):
    for k in b:files[k]['batch']=i
for r in rows:r['batch']=files[r['file']]['batch']
json.dump(dict(batches=[dict(batch=i,areas=sorted({files[k]['area'] for k in b}),code_lines=sum(files[k]['code'] for k in b),files=b) for i,b in enumerate(batches,1)],
  plan=[{k:v for k,v in r.items() if k not in('area',)} | {'area':r['area']} for r in rows],
  files={k:{**v,'viol_kinds':dict(v['viol_kinds']),'actions':dict(v['actions'])} for k,v in files.items()}),open('/tmp/claude-0/s/comment_plan.json','w'),indent=1)
json.dump(dict(rows=rows,files=files),open('/tmp/claude-0/s/_raw.json','w'),default=str)
print(len(rows),len(files),len(groutines))
