import puppeteer from 'puppeteer-core';
import { join } from 'path';

const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const screenshotDir = 'C:\\Users\\TUF GAMING\\Documents\\GitHub\\ilkom22-paralel-5\\docs\\screenshots';
const appUrl = 'http://localhost:5173';

async function clickNav(page, label) {
  const buttons = await page.$$('.nav-link');

  for (const button of buttons) {
    const text = await page.evaluate((element) => element.textContent.trim(), button);
    if (text === label) {
      await button.click();
      await new Promise((resolve) => setTimeout(resolve, 900));
      return;
    }
  }

  throw new Error(`Navigation button not found: ${label}`);
}

async function run() {
  console.log('Launching Chrome...');
  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 950 });

  console.log(`Navigating to ${appUrl}...`);
  await page.goto(appUrl, { waitUntil: 'networkidle2' });

  console.log('Waiting for the hospital UI to settle...');
  await new Promise((resolve) => setTimeout(resolve, 1200));

  console.log('Capturing home page...');
  await page.screenshot({ path: join(screenshotDir, 'hospital_home.png'), fullPage: true });

  const pages = [
    { label: 'Cari Dokter', filename: 'hospital_doctors.png' },
    { label: 'Layanan Kesehatan', filename: 'hospital_services.png' },
    { label: 'Info & Media', filename: 'hospital_news.png' },
    { label: 'Admin RS', filename: 'hospital_admin.png', waitMs: 2500 }
  ];

  for (const appPage of pages) {
    console.log(`Capturing ${appPage.label} page...`);
    await clickNav(page, appPage.label);
    await new Promise((resolve) => setTimeout(resolve, appPage.waitMs ?? 1200));
    await page.screenshot({ path: join(screenshotDir, appPage.filename), fullPage: true });
  }

  console.log('Done capturing screenshots!');
  await browser.close();
}

run().catch(err => {
  console.error('Error running screenshot script:', err);
  process.exit(1);
});
