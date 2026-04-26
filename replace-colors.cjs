const fs = require('fs');
const files = [
  'src/pages/Dashboard.jsx',
  'src/pages/Analytics.jsx',
  'src/pages/Habits.jsx',
  'src/layouts/DashboardLayout.jsx',
  'src/store/useStore.js',
  'src/pages/Landing.jsx',
  'src/index.css',
  'src/components/ParticlesBackground.jsx'
];

const replacements = {
  '#EA580C': '#FF6B2C',
  'rgba(234, 88, 12': 'rgba(255, 107, 44',
  'rgba(234,88,12': 'rgba(255,107,44',
  '#DC2626': '#E85D04',
  '#F59E0B': '#FF8C42',
  '#B91C1C': '#E85D04',
  '#D97706': '#FF8C42',
  '#991B1B': '#FF6B2C',
  '#F97316': '#FF8C42',
  'rgba(220, 38, 38': 'rgba(232, 93, 4',
  'rgba(255, 140, 50': 'rgba(255, 107, 44'
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
