const fs = require('fs');
const { createCanvas, loadImage, registerFont } = require('canvas');
const toml = require('toml');
const matter = require('gray-matter');
const path = require('path');

const width = 1200;
const height = 630;
const maxWidth = 550;
const paddingLeft = 50;
const videosDir = path.join(__dirname, 'content/videos');

// By default we only generate images that don't exist yet. Pass --force
// (e.g. `yarn build --force`, run by `make rebuild`) to regenerate everything.
const force = process.argv.includes('--force');

process.stdout.write(`generating images${force ? ' (--force)' : ''}\n`);

const fontPath = path.join(__dirname, 'static/fonts/PoetsenOne-Regular.ttf');

if (!fs.existsSync(fontPath)) {
  throw new Error('Font file not found!');
}

registerFont(fontPath,{ family: 'PoetsenOne' });

const getFontSize = (title) => {
    const len = title.length;
    if (len <= 40) return 64;
    if (len <= 60) return 52;
    return 42;
};

const generateOgImage = async (title, dest) => {
    const canvas = createCanvas(width, height);
    const context = canvas.getContext('2d');

    const baseImage = await loadImage(path.join(__dirname, 'static/images/sheerio-guitar.png'));
    context.drawImage(baseImage, 0, 0, width, height);

    const fontSize = getFontSize(title);
    const lineHeight = Math.round(fontSize * 1.4);

    context.fillStyle = '#374151';
    context.font = `${fontSize}px "PoetsenOne"`;

    const words = title.split(' ');
    let line = '';
    let y = lineHeight / 2;
    const headlines = [];

    words.forEach((w, i) => {
        const testLine = `${line}${w} `;
        const metrics = context.measureText(testLine);
        if (metrics.width > maxWidth && i > 0) {
            headlines.push({ text: line, y });
            line = `${w} `;
            y += lineHeight;
        } else {
            line = testLine;
        }
    });
    headlines.push({ text: line, y });

    const startPosY = (height - (lineHeight * headlines.length)) / 2;
    headlines.forEach((l) => context.fillText(l.text, paddingLeft, startPosY + l.y));

    context.fillStyle = '#006cb0';
    context.fillRect(paddingLeft, startPosY - (lineHeight / 2) - 10, 100, 5);

    const buffer = canvas.toBuffer('image/png');
    fs.writeFileSync(path.join(dest), buffer);
};

// Generate the share image. By default we skip it when an up-to-date image
// already exists; we still regenerate when the source markdown (`src`) is newer
// than the image (e.g. the title changed), or when --force is given.
const generateOgImageIfNeeded = async (title, dest, src) => {
    if (!force && fs.existsSync(dest)) {
        const upToDate = !src || fs.statSync(dest).mtimeMs >= fs.statSync(src).mtimeMs;
        if (upToDate) {
            process.stdout.write(`skip   ${dest}\n`);
            return;
        }
        process.stdout.write(`stale  ${dest}\n`);
    } else {
        process.stdout.write(`new    ${dest}\n`);
    }
    await generateOgImage(title, dest);
};

const readTitle = (mdPath) => {
    const content = fs.readFileSync(mdPath, 'utf-8');
    const { data } = matter(content, { delimiters: '+++', engines: { toml: { parse: toml.parse.bind(toml) } }, language: 'toml' });
    return data.title;
};

// Per-video share images.
const generateForVideos = async () => {
    const files = fs.readdirSync(videosDir);
    for (const folder of files) {
        const folderPath = path.join(videosDir, folder);
        if (!fs.statSync(folderPath).isDirectory()) continue;
        const indexMd = path.join(folderPath, 'index.md');
        const title = readTitle(indexMd);
        await generateOgImageIfNeeded(title, path.join(folderPath, 'feature-image.png'), indexMd);
    }
};

// Landing/section pages. They share the same template + title treatment as videos.
// `title` overrides the front-matter title (used for the home page, which has none).
const sectionPages = [
    { md: 'content/_index.md', title: 'Sheerio Online' },
    { md: 'content/video-of-the-day/index.md' },
    { md: 'content/videos/_index.md' },
    { md: 'content/timeline/_index.md' },
    { md: 'content/tags/_index.md' },
];

const generateForSections = async () => {
    for (const page of sectionPages) {
        const mdPath = path.join(__dirname, page.md);
        const title = page.title || readTitle(mdPath);
        const dest = path.join(path.dirname(mdPath), 'feature-image.png');
        await generateOgImageIfNeeded(title, dest, mdPath);
    }
};

(async () => {
    await generateForVideos();
    await generateForSections();
})();
