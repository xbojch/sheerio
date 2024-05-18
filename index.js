const fs = require('fs');
const { createCanvas, loadImage, registerFont } = require('canvas');
const toml = require('toml');
const matter = require('gray-matter');
const path = require('path');


const width = 1200;
const height = 630;
const maxWidth = 700;
const lineHeight = 90;
const paddingLeft = 50;
const dir = path.join(__dirname, 'content/videos');

process.stdout.write(`generating images\n`);

const generateOgImage = async (title, tags, dest) => {
    const canvas = createCanvas(width, height);
    const context = canvas.getContext('2d');

    const baseImage = await loadImage(path.join(__dirname, 'static/images/sheerio-guitar.png'));
    context.drawImage(baseImage, 0, 0, width, height);

    registerFont(
        path.join(__dirname, 'static/fonts/PoetsenOne-Regular.ttf'),
        { family: 'PoetsenOne' },
    );

    context.fillStyle = '#374151';
    context.font = '64px PoetsenOne';

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

fs.readdir(dir, (err, files) => {
    files.forEach((folder) => {
        const stat = fs.statSync(`${dir}/${folder}`);
        if (stat && stat.isDirectory()) {
            process.stdout.write(`${dir}/${folder}\n`);
            const content = fs.readFileSync(`${dir}/${folder}/index.md`, 'utf-8');
            const { data: post } = matter(content, { delimiters: '+++', engines: { toml: { parse: toml.parse.bind(toml) } }, language: 'toml' });
            generateOgImage(post.title, post.tags, `${dir}/${folder}/feature-image.png`);
        }
    });
});