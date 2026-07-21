
from bs4 import BeautifulSoup
import json
from pathlib import Path

def extract_structured_data(html_files_dir):
    """Extract structured data from HTML/XML files using Beautiful Soup"""
    extracted_data = []
    
    for html_file in Path(html_files_dir).rglob("*.html"):
        with open(html_file, 'r', encoding='utf-8', errors='ignore') as f:
            soup = BeautifulSoup(f.read(), 'html.parser')
            
            # Extract code blocks, scripts, and structured content
            data = {
                "source_file": str(html_file),
                "title": soup.title.string if soup.title else None,
                "scripts": [script.string for script in soup.find_all('script') if script.string],
                "code_blocks": [pre.get_text() for pre in soup.find_all('pre')],
                "links": [a.get('href') for a in soup.find_all('a', href=True)],
                "metadata": {meta.get('name'): meta.get('content') for meta in soup.find_all('meta')}
            }
            extracted_data.append(data)
    
    # Save extracted data
    output_file = Path("/data/data/com.termux/files/home/constellation25_sovereign_data/extracted_structured_data.json")
    with open(output_file, 'w') as f:
        json.dump(extracted_data, f, indent=2)
    
    print(f"✅ Beautiful Soup extraction complete: {len(extracted_data)} files parsed")
    return output_file

if __name__ == "__main__":
    extract_structured_data("/data/data/com.termux/files/home/constellation25_sovereign_data")
