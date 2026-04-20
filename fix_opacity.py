import os
import re

d = '/Users/veeranandhanvj/flutter_base/lib/app/'

replacements = [
    (r'opacity: value,', r'opacity: value.clamp(0.0, 1.0),'),
    (r'opacity: value\)', r'opacity: value.clamp(0.0, 1.0))'),
    (r'opacity: anim1\.value,', r'opacity: anim1.value.clamp(0.0, 1.0),'),
    (r'opacity: anim1\.value\)', r'opacity: anim1.value.clamp(0.0, 1.0))')
]

for root, _, files in os.walk(d):
    for f in files:
        if f.endswith('.dart'):
            path = os.path.join(root, f)
            with open(path, 'r') as file:
                content = file.read()
                
            orig_content = content
            for pat, repl in replacements:
                content = re.sub(pat, repl, content)
                
            if content != orig_content:
                with open(path, 'w') as file:
                    file.write(content)
                print(f"Fixed {path}")

