import zipfile,os
root=os.path.expanduser('~/.m2/repository')
matches=[]
for dirpath,_,files in os.walk(root):
    for f in files:
        if f.endswith('.jar'):
            p=os.path.join(dirpath,f)
            try:
                with zipfile.ZipFile(p) as z:
                        if pat in z.namelist():
                            matches.append(p)
            except Exception:
                pass
for m in matches:
    print(m)
print('total',len(matches))
