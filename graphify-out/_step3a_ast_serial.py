import sys, json
from pathlib import Path

# Try sequential extraction without multiprocessing
import importlib
import graphify.extract as ext_mod

code_files = []
detect = json.loads(Path('graphify-out/.graphify_detect.json').read_text(encoding='utf-8'))
for f in detect.get('files', {}).get('code', []):
    p = Path(f)
    if p.is_dir():
        from graphify.extract import collect_files
        code_files.extend(collect_files(p))
    else:
        code_files.append(p)

print(f'Processing {len(code_files)} code files with sequential extraction')

try:
    # Try calling the internal function directly if available
    from graphify.extract import _extract_per_file
    result = _extract_per_file(code_files, Path('.'))
except (ImportError, AttributeError):
    # Fall back to regular extract but try with different options
    from graphify.extract import extract
    result = extract(code_files, cache_root=Path('.'), max_workers=1, per_file=True)

if result.get('nodes') or result.get('edges'):
    Path('graphify-out/.graphify_ast.json').write_text(
        json.dumps(result, indent=2, ensure_ascii=False), encoding='utf-8'
    )
    print(f'AST: {len(result["nodes"])} nodes, {len(result["edges"])} edges')
else:
    # Create empty result
    Path('graphify-out/.graphify_ast.json').write_text(
        json.dumps({'nodes':[],'edges':[],'input_tokens':0,'output_tokens':0}, ensure_ascii=False), encoding='utf-8'
    )
    print('AST extraction produced no results - using empty graph')
