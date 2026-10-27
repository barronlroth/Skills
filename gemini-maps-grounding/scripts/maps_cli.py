#!/usr/bin/env python3
"""Maps-first recommendations via gemini-api's default model. No model pin."""
import argparse,json,os,subprocess,sys,tempfile,shutil
from pathlib import Path

def credentials():
    env=os.environ.copy()
    if not env.get('GEMINI_API_KEY') and env.get('GOOGLE_API_KEY'):
        env['GEMINI_API_KEY']=env['GOOGLE_API_KEY']
    return env

def main():
    a=argparse.ArgumentParser(description=__doc__)
    a.add_argument('query');a.add_argument('--lat',type=float);a.add_argument('--lng',type=float)
    a.add_argument('--with-search',action='store_true');a.add_argument('--dry-run',action='store_true')
    a.add_argument('--out-dir',type=Path);a.add_argument('--timeout',type=int,default=180)
    args=a.parse_args()
    if (args.lat is None)!=(args.lng is None):a.error('Supply both --lat and --lng, or neither')
    if args.lat is not None and not (-90<=args.lat<=90 and -180<=args.lng<=180):a.error('Invalid coordinates')
    root=Path(tempfile.gettempdir())
    root.mkdir(parents=True,exist_ok=True)
    out=args.out_dir or Path(tempfile.mkdtemp(prefix='maps-cli-',dir=root));out.mkdir(parents=True,exist_ok=True)
    tool={'type':'google_maps'}
    if args.lat is not None:tool.update(latitude=args.lat,longitude=args.lng)
    tools=[tool]+([{'type':'google_search'}] if args.with_search else [])
    body={'input':args.query,'tools':tools,'store':False}
    request=out/'request.json';request.write_text(json.dumps(body))
    exe=os.environ.get('GEMINI_API_BIN') or shutil.which('gemini-api')
    if not exe:a.error('Install gemini-api and put it on PATH, or set GEMINI_API_BIN')
    cmd=[exe,'generate','--body','@'+str(request),'--stream=false','--output-format','json']
    if args.dry_run:cmd.append('--dry-run')
    env=os.environ.copy() if args.dry_run else credentials()
    r=subprocess.run(cmd,env=env,capture_output=True,text=True,timeout=args.timeout)
    raw=out/('dry-run.json' if args.dry_run else 'response.json');raw.write_text(r.stdout);raw.chmod(0o600)
    (out/'stderr.txt').write_text(r.stderr)
    if r.returncode:
        print(json.dumps({'error':'gemini-api failed','exit_code':r.returncode,'stderr_path':str(out/'stderr.txt'),'detail':r.stderr[:1800]}));return r.returncode
    d=json.loads(r.stdout)
    if args.dry_run:print(json.dumps({'request':body,'cli_preview':d,'artifact':str(raw)}));return 0
    texts=[];citations=[];calls=[]
    for step in d.get('steps',[]):
        if step.get('type','').endswith('_call'):calls.append(step['type'])
        if step.get('type')=='model_output':
            for content in step.get('content',[]):
                if content.get('text'):texts.append(content['text'])
                citations.extend(x for x in content.get('annotations',[]) if x.get('type') in ['place_citation','url_citation'])
    result={'text':'\n'.join(texts),'citations':citations,'tool_calls':calls,'usage':d.get('usage'),'raw_response':str(raw),'model_policy':'CLI default (no override)'}
    print(json.dumps(result,ensure_ascii=False));return 0
if __name__=='__main__':sys.exit(main())
