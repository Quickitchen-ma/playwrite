# Use a Node.js base image. 'bullseye-slim' is a good choice for stability and size.
FROM node:18-bullseye-slim

# Set the working directory inside the container
WORKDIR /app

# Install Playwright's required system dependencies
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
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Install Playwright browsers (Chromium specifically)
RUN npx playwright install chromium

# *** ADD THIS LINE TO EXPLICITLY SET THE PLAYWRIGHT BROWSER PATH ***
ENV PLAYWRIGHT_BROWSERS_PATH=/root/.cache/ms-playwright

# Copy the rest of your application code
COPY . .

# Set the port your Express app listens on
ENV PORT=3000
EXPOSE 3000

# Define the command to start your application
CMD ["npm", "start"]