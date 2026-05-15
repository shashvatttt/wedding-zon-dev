const fs = require('fs');
const path = require('path');

const files = [
    'client/public/locales/en/common.json',
    'client/public/locales/hi/common.json',
    'client/public/locales/pa/common.json'
];

files.forEach(file => {
    try {
        const content = fs.readFileSync(file, 'utf8');
        const json = JSON.parse(content);
        console.log(`✅ ${file} is valid JSON.`);
        if (json.nav && json.nav.home) {
            console.log(`   Contains nav.home: "${json.nav.home}"`);
        } else {
            console.error(`   ❌ Missing nav.home in ${file}`);
        }
    } catch (err) {
        console.error(`❌ Error parsing ${file}:`, err.message);
    }
});
