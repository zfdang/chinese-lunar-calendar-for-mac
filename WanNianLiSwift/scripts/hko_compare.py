import re,glob,sys
S=sys.argv[1]
months={"正":1,"一":1,"二":2,"三":3,"四":4,"五":5,"六":6,"七":7,"八":8,"九":9,"十":10,"十一":11,"十二":12,"冬":11,"臘":12}
days={}
for i,p in enumerate(["初","十","廿","卅"]):
    pass
def dayval(s):
    if s=="初十":return 10
    if s=="二十":return 20
    if s=="三十":return 30
    d="一二三四五六七八九"
    base={"初":0,"十":10,"廿":20,"卅":30}[s[0]]
    return base+d.index(s[1])+1
t2s={"驚蟄":"惊蛰","穀雨":"谷雨","小滿":"小满","芒種":"芒种","處暑":"处暑","白露":"白露","霜降":"霜降","立冬":"立冬","小雪":"小雪","大雪":"大雪","冬至":"冬至","雨水":"雨水","春分":"春分","清明":"清明","立夏":"立夏","夏至":"夏至","小暑":"小暑","大暑":"大暑","立秋":"立秋","秋分":"秋分","寒露":"寒露","小寒":"小寒","大寒":"大寒","立春":"立春"}
hko={}
cur=None
for f in sorted(glob.glob(S+"/hko/T*.txt")):
    for line in open(f,encoding="utf-8-sig"):
        m=re.match(r"(\d{4})年(\d{1,2})月(\d{1,2})日\s+(\S+)\s+星期\S\s*(\S*)",line)
        if not m: continue
        key="%s%02d%02d"%(m[1],int(m[2]),int(m[3])); l=m[4]; jq=t2s.get(m[5],m[5])
        if l.endswith("月"):
            leap=l.startswith("閏"); name=l[1:-1] if leap else l[:-1]
            cur=(months[name],leap); d=1
        else: d=dayval(l)
        if cur: hko[key]=(cur[0],d,int(cur[1]),jq)
def load(p):
    r={}
    for line in open(p):
        c=line.rstrip("\n").split("\t"); r[c[0]]=(int(c[1]),int(c[2]),int(c[3]),c[8])
    return r
import os
for name in ["js","swift"]:
    if not os.path.exists(f"{S}/{name}.tsv"):
        continue
    r=load(f"{S}/{name}.tsv"); bad_l=[];bad_j=[]
    for k,v in r.items():
        h=hko.get(k)
        if not h: continue
        if v[:3]!=h[:3]: bad_l.append(k)
        if v[3]!=h[3]: bad_j.append(k)
    yrs=sorted(set(k[:4] for k in bad_l))
    print(f"{name}: lunar-date mismatches={len(bad_l)} years={yrs}; solar-term mismatches={len(bad_j)} {bad_j[:20]}")
