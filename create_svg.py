import os

export_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <path d="M24 4L24 30M24 4L16 12M24 4L32 12" stroke="#FF9800" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M8 28V38C8 40.2091 9.79086 42 12 42H36C38.2091 42 40 40.2091 40 38V28" stroke="#FF9800" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
</svg>'''

import_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="none">
  <path d="M24 30L24 4M24 30L16 22M24 30L32 22" stroke="#4CAF50" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M8 28V38C8 40.2091 9.79086 42 12 42H36C38.2091 42 40 40.2091 40 38V28" stroke="#4CAF50" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
</svg>'''

os.makedirs('entry/src/main/resources/base/media', exist_ok=True)
with open('entry/src/main/resources/base/media/ic_public_export.svg', 'w', encoding='utf-8') as f:
    f.write(export_svg)
with open('entry/src/main/resources/base/media/ic_public_import.svg', 'w', encoding='utf-8') as f:
    f.write(import_svg)
print('SVG files created successfully')