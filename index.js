const express = require('express');
const { chromium } = require('playwright'); // You can also use 'firefox' or 'webkit'

const app = express();
const PORT = 3000; // Choose a port, e.g., 3000. Make sure it's open on your VPS firewall.

app.use(express.json());

app.get('/scrape-binance-announcements', async (req, res) => {
    let browser;
    try {
        browser = await chromium.launch({ headless: true }); // headless: true for production
        const page = await browser.newPage();

        // Set a realistic user-agent to mimic a real browser
        await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.88 Safari/537.36');

        await page.goto('https://www.binance.com/en/support/announcement/list/48', { waitUntil: 'domcontentloaded' });

        // Wait for the specific JavaScript challenge to resolve or content to appear
        // This is crucial. You might need to adjust the waiting strategy.
        // It could be waiting for a specific selector that appears after the JS challenge resolves.
        // For AWS WAF, sometimes waiting for network idle or a specific element to be visible helps.
        await page.waitForSelector('a.css-6f91y1', { timeout: 60000 }); // Wait for the announcement links to be present (adjust timeout if needed)

        const announcements = await page.$$eval('a.css-6f91y1', (elements) => {
            const data = [];
            elements.forEach(el => {
                const title = el.textContent.trim();
                const href = el.getAttribute('href');
                let listing_type = '';

                if (/(will list|lists)/i.test(title)) {
                    listing_type = 'listing';
                } else if (/(will delist|delists)/i.test(title)) {
                    listing_type = 'delisting';
                }

                if (listing_type) {
                    data.push({
                        title: title,
                        url: `https://www.binance.com${href}`,
                        listing_type: listing_type
                    });
                }
            });
            return data;
        });

        res.json(announcements);

    } catch (error) {
        console.error('Scraping error:', error);
        res.status(500).json({ error: 'Failed to scrape Binance announcements', details: error.message });
    } finally {
        if (browser) {
            await browser.close();
        }
    }
});

app.listen(PORT, () => {
    console.log(`Playwright scraper service listening on port ${PORT}`);
});