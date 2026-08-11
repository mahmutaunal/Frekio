from pathlib import Path
import re, sys

root = Path(__file__).resolve().parents[1]
required = [
    'pubspec.yaml','lib/main.dart','lib/src/services/radio_audio_handler.dart',
    'android/app/src/main/AndroidManifest.xml','ios/Runner/Info.plist',
    'PRIVACY.md','LICENSE','docs/RELEASE_CHECKLIST.md',
]
missing=[p for p in required if not (root/p).exists()]
if missing:
    print('Missing required files:', *missing, sep='\n- ')
    sys.exit(1)

texts=[]
for p in root.rglob('*'):
    if p.is_file() and p.suffix.lower() in {'.dart','.yaml','.yml','.md','.xml','.plist','.kts','.swift','.sh'}:
        try: texts.append((p,p.read_text(encoding='utf-8')))
        except UnicodeDecodeError: pass
forbidden=['com.alpwarestudio.ahenk','package:ahenk_radio/']
hits=[(p,str(f)) for p,t in texts for f in forbidden if f in t]
if hits:
    print('Old identity references found:',hits);sys.exit(1)
print(f'Source package structure OK: {sum(1 for p in root.rglob("*") if p.is_file())} files')
