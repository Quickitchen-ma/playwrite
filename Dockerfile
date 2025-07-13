# Use a Node.js base image. 'bullseye-slim' is a good choice for stability and size.
# Playwright's documentation often recommends a Debian-based image for broad compatibility.
FROM node:18-bullseye-slim

# Set the working directory inside the container
WORKDIR /app

# Install Playwright's required system dependencies
# These are essential for Chromium to run headless in a lean environment.
# This list is comprehensive and derived from Playwright's own documentation for Debian/Ubuntu.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    # Clean up APT cache to reduce image size
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy package.json and package-lock.json to leverage Docker caching
# This step is done separately so npm install isn't re-run if only app code changes
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Install Playwright browsers (Chromium specifically, as per your postinstall script)
# This explicitly downloads the browser binaries into node_modules
RUN npx playwright install chromium

# Copy the rest of your application code
COPY . .

# Set the port your Express app listens on (ensure this matches your app.listen(PORT))
ENV PORT 3000
EXPOSE 3000

# Define the command to start your application
CMD ["npm", "start"]