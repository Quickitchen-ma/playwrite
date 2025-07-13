# Use a Node.js base image that is suitable for Playwright.
# 'lts-slim' is generally good for production as it's smaller.
# Playwright often benefits from a more complete base image for dependencies.
FROM node:18-slim

# Set the working directory inside the container
WORKDIR /app

# Install Playwright's required system dependencies
# These are crucial for Chromium to run headless in a slim environment
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    fontconfig \
    locales \
    gconf-service \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
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
    ca-certificates \
    fonts-liberation \
    libappindicator1 \
    libnss3-altfiles \
    lsb-release \
    xdg-utils \
    # Clean up APT cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json to leverage Docker caching
# This step is done separately so npm install isn't re-run if only app code changes
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Install Playwright browsers and their system dependencies
# This command explicitly downloads the browser binaries into node_modules
RUN npx playwright install --with-deps

# Copy the rest of your application code
COPY . .

# Set the port your Express app listens on
ENV PORT 3000
EXPOSE 3000

# Define the command to start your application
CMD ["npm", "start"]