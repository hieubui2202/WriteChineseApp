import { mkdir, copyFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const source = join(__dirname, '..', '..', 'admin', 'hanzi_admin_console.html');
const destinationDir = join(__dirname, '..', '..', 'web', '_admin');
const destination = join(destinationDir, 'index.html');

await mkdir(destinationDir, { recursive: true });
await copyFile(source, destination);
console.log(`Copied admin console to ${destination}`);
