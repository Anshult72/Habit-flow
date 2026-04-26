const fs = require('fs');
const files = [
  'src/pages/Landing.jsx',
  'src/pages/Dashboard.jsx',
  'src/pages/Analytics.jsx',
  'src/pages/Habits.jsx',
  'src/layouts/DashboardLayout.jsx',
];

const replacements = {
  // Specific complex fixes
  'from-primary via-accent to-secondary': 'from-[#FF6B2C] via-[#FF8C42] to-[#E85D04]',
  'from-primary/20 to-secondary/20': 'from-[#FF6B2C]/20 to-[#E85D04]/20',
  'from-primary to-secondary': 'from-[#FF6B2C] to-[#E85D04]',
  'from-accent to-primary': 'from-[#FF8C42] to-[#FF6B2C]',
  'from-primary to-accent': 'from-[#FF6B2C] to-[#FF8C42]',

  // Classes
  'bg-primary': 'bg-[#FF6B2C]',
  'text-primary': 'text-[#FF6B2C]',
  'border-primary': 'border-[#FF6B2C]',
  'from-primary': 'from-[#FF6B2C]',
  'to-primary': 'to-[#FF6B2C]',
  'via-primary': 'via-[#FF6B2C]',
  
  'bg-secondary': 'bg-[#E85D04]',
  'text-secondary': 'text-[#E85D04]',
  'border-secondary': 'border-[#E85D04]',
  'from-secondary': 'from-[#E85D04]',
  'to-secondary': 'to-[#E85D04]',
  'via-secondary': 'via-[#E85D04]',
  
  'bg-accent': 'bg-[#FF8C42]',
  'text-accent': 'text-[#FF8C42]',
  'border-accent': 'border-[#FF8C42]',
  'from-accent': 'from-[#FF8C42]',
  'to-accent': 'to-[#FF8C42]',
  'via-accent': 'via-[#FF8C42]',
};

files.forEach(file => {
  if (fs.existsSync(file)) {
    let content = fs.readFileSync(file, 'utf8');
    for (const [key, value] of Object.entries(replacements)) {
      content = content.split(key).join(value);
    }
    fs.writeFileSync(file, content);
    console.log('Updated ' + file);
  }
});
