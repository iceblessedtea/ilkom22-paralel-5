import puppeteer from 'puppeteer-core';
import { join } from 'path';

const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const screenshotDir = 'C:\\Users\\TUF GAMING\\Documents\\GitHub\\ilkom22-paralel-5\\docs\\screenshots';

async function run() {
  console.log('Launching Chrome...');
  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 800 });

  console.log('Navigating to http://localhost:5173...');
  await page.goto('http://localhost:5173', { waitUntil: 'networkidle2' });

  // Wait extra 3 seconds for database results to render
  console.log('Waiting for data to load...');
  await new Promise(r => setTimeout(r, 3000));

  // Screenshot 1: Patients (default active tab)
  console.log('Capturing Patients view...');
  await page.screenshot({ path: join(screenshotDir, 'dashboard_patients.png') });

  // Navigation Items
  const tabs = [
    { label: 'Dokter', filename: 'dashboard_doctors.png' },
    { label: 'Janji Temu', filename: 'dashboard_appointments.png' },
    { label: 'Rekam Medis', filename: 'dashboard_medical_records.png' }
  ];

  for (const tab of tabs) {
    console.log(`Clicking on tab: ${tab.label}`);
    
    // Find button by text in navigation
    const buttons = await page.$$('.nav-stack button');
    let clicked = false;
    for (const btn of buttons) {
      const text = await page.evaluate(el => el.textContent.trim(), btn);
      if (text.includes(tab.label)) {
        await btn.click();
        clicked = true;
        break;
      }
    }

    if (!clicked) {
      console.error(`Failed to find button for tab: ${tab.label}`);
      continue;
    }

    // Wait for data load
    await new Promise(r => setTimeout(r, 2000));

    console.log(`Capturing ${tab.label} view...`);
    await page.screenshot({ path: join(screenshotDir, tab.filename) });
  }

  console.log('Done capturing screenshots!');
  await browser.close();
}

run().catch(err => {
  console.error('Error running screenshot script:', err);
  process.exit(1);
});
