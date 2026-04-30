const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');
const yaml = require('js-yaml');

// Categories to match awesome-copilot format (chatmodes migrated to agents)
const categories = ['instructions', 'prompts', 'agents'];
const index = {
  generated: new Date().toISOString(),
  instructions: [],
  prompts: [],
  agents: [],
  collections: []
};

// Process markdown files for instructions, prompts, and chatmodes
categories.forEach(category => {
  const categoryDir = path.join('.', category);

  if (fs.existsSync(categoryDir)) {
    const files = fs.readdirSync(categoryDir).filter(f => f.endsWith('.md'));

    files.forEach(filename => {
      const filePath = path.join(categoryDir, filename);
      const content = fs.readFileSync(filePath, 'utf8');
      const parsed = matter(content);
      const data = parsed.data;

      index[category].push({
        filename: filename,
        title: data.title || filename.replace('.md', ''),
        description: `"${data.description || 'No description provided'}"`,
        link: `${category}/${filename}`
      });
    });
  }
});

// Process YAML files for collections
const collectionsDir = path.join('.', 'collections');
if (fs.existsSync(collectionsDir)) {
  const files = fs.readdirSync(collectionsDir).filter(f => f.endsWith('.collection.yml') || f.endsWith('.collection.yaml'));

  files.forEach(filename => {
    const filePath = path.join(collectionsDir, filename);
    const content = fs.readFileSync(filePath, 'utf8');

    try {
      const data = yaml.load(content);

      index.collections.push({
        filename: filename,
        title: data.name || data.id || filename.replace(/\.collection\.(yml|yaml)$/, ''),
        description: data.description || 'No description provided',
        link: `collections/${filename}`
      });
    } catch (error) {
      console.error(`Error parsing ${filename}:`, error.message);
    }
  });
}

fs.writeFileSync('index.json', JSON.stringify(index, null, 2));
console.log(`Generated index.json with ${Object.values(index).filter(Array.isArray).flat().length} total items`);
