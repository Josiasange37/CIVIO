const fs = require('fs');
const path = require('path');
const emojiRegex = /[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F000}-\u{1F02F}\u{1F0A0}-\u{1F0FF}\u{1F1E6}-\u{1F1FF}\u{1F200}-\u{1F25F}\u{1F21A}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}]/gu;

function searchFiles(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            searchFiles(fullPath);
        } else if (fullPath.endsWith('.tsx') || fullPath.endsWith('.ts')) {
            const content = fs.readFileSync(fullPath, 'utf8');
            let match;
            while ((match = emojiRegex.exec(content)) !== null) {
                console.log(`${fullPath}: ${match[0]}`);
            }
        }
    }
}
searchFiles('/home/almight/ekema/admin-panel/src');
