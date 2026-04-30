#!/usr/bin/env python3

"""
Generate vscode:// installation links for Awesome Copilot items

Usage:
    python generate-link.py <type> <path> [target] [publisher]

Examples:
    python generate-link.py prompt prompts/test-gen.prompt.md
    python generate-link.py instruction instructions/java.instructions.md global
    python generate-link.py collection collections/react-bundle.collection.yml ask my-publisher
"""

import sys
from urllib.parse import urlencode

# Default configuration - update these values
DEFAULT_PUBLISHER = 'your-publisher-name'
EXTENSION_NAME = 'awesome-copilot-ghe'

def generate_link(type_name, path, target='ask', publisher=DEFAULT_PUBLISHER):
    """Generate a vscode:// installation link"""
    base_url = f'vscode://{publisher}.{EXTENSION_NAME}/install'
    params = urlencode({'type': type_name, 'link': path, 'target': target})
    return f'{base_url}?{params}'

def print_usage():
    """Print usage information"""
    print('Generate vscode:// installation links')
    print('')
    print('Usage:')
    print('  python generate-link.py <type> <path> [target] [publisher]')
    print('')
    print('Parameters:')
    print('  type       instruction|prompt|agent|chatmode|collection')
    print('  path       Path to the item (e.g., prompts/example.prompt.md)')
    print('  target     global|workspace|view|ask (default: ask)')
    print(f'  publisher  Your publisher name (default: {DEFAULT_PUBLISHER})')
    print('')
    print('Examples:')
    print('  python generate-link.py prompt prompts/test-gen.prompt.md')
    print('  python generate-link.py instruction instructions/java.instructions.md global')
    print('  python generate-link.py collection collections/bundle.collection.yml ask')

def main():
    """Main entry point"""
    args = sys.argv[1:]
    
    if len(args) == 0 or '--help' in args or '-h' in args:
        print_usage()
        sys.exit(0)
    
    if len(args) < 2:
        print('❌ Error: Missing required parameters\n')
        print_usage()
        sys.exit(1)
    
    type_name = args[0]
    path = args[1]
    target = args[2] if len(args) > 2 else 'ask'
    publisher = args[3] if len(args) > 3 else DEFAULT_PUBLISHER
    
    # Validate type
    valid_types = ['instruction', 'instructions', 'prompt', 'prompts', 'agent', 
                   'agents', 'chatmode', 'chatmodes', 'collection', 'collections']
    if type_name.lower() not in valid_types:
        print(f'❌ Error: Invalid type "{type_name}"')
        print(f'   Valid types: {", ".join(valid_types)}')
        sys.exit(1)
    
    # Validate target
    valid_targets = ['global', 'workspace', 'view', 'ask']
    if target.lower() not in valid_targets:
        print(f'❌ Error: Invalid target "{target}"')
        print(f'   Valid targets: {", ".join(valid_targets)}')
        sys.exit(1)
    
    # Generate the link
    link = generate_link(type_name, path, target, publisher)
    filename = path.split('/')[-1]
    
    print('✅ Generated installation link:\n')
    print('📋 Raw URL:')
    print(link)
    print('')
    print('📝 Markdown:')
    print(f'[Install {filename}]({link})')
    print('')
    print('🌐 HTML:')
    print(f'<a href="{link}">Install {filename}</a>')
    print('')
    print('🎨 HTML Button:')
    print(f'<a href="{link}" style="background:#007acc;color:white;padding:8px 16px;'
          f'text-decoration:none;border-radius:4px;display:inline-block">📥 Install {filename}</a>')
    print('')
    print('🔖 Badge (Shields.io):')
    print(f'[![Install](https://img.shields.io/badge/Install-VS%20Code-blue)]({link})')

if __name__ == '__main__':
    main()

