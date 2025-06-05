#!/bin/bash
# PiSpot Node.js Control Panel Setup Script
# This script sets up a Node.js Express server for PiSpot control

set -e

APP_DIR="$HOME/pispot_node_server"
PORT=${1:-3030}

# Install Node.js and npm if not present
if ! command -v node >/dev/null 2>&1; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Create app directory
sudo mkdir -p "$APP_DIR"
sudo chown "$USER":"$USER" "$APP_DIR"
cd "$APP_DIR"

# Create package.json if missing
if [ ! -f package.json ]; then
    sudo npm init -y
fi

# Add dependencies to package.json
cat > package.json <<EOPKG
{
  "name": "pispot_node_server",
  "version": "1.0.0",
  "main": "server.js",
  "license": "UNLICENSED",
  "dependencies": {
    "express": "^4.18.2",
    "multer": "^1.4.5"
  }
}
EOPKG

# Install dependencies
sudo npm install

# Create server.js
cat > server.js <<'EOF'
const express = require('express');
const fs = require('fs');
const { exec } = require('child_process');
const multer = require('multer');
const upload = multer({ dest: '/tmp' });
const app = express();
const port = process.env.PORT || parseInt(process.argv[2]) || 3030;

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

function isGadgetModeEnabled() {
  try {
    const configTxt = fs.readFileSync('/boot/config.txt', 'utf8');
    const cmdlineTxt = fs.readFileSync('/boot/cmdline.txt', 'utf8');
    return configTxt.includes('dtoverlay=dwc2') && cmdlineTxt.includes('g_mass_storage');
  } catch (e) {
    return false;
  }
}

function getUsbFiles() {
  try {
    // Mount the image if not mounted
    if (!fs.existsSync('/mnt/usb_drive')) {
      fs.mkdirSync('/mnt/usb_drive');
    }
    exec('sudo mount | grep /mnt/usb_drive', (err, stdout) => {
      if (!stdout) {
        exec('sudo mount -o loop /usb_drive.img /mnt/usb_drive', () => {});
      }
    });
    // Wait a bit for mount
    return fs.readdirSync('/mnt/usb_drive');
  } catch (e) {
    return ['(not mounted or empty)'];
  }
}

app.get('/', (req, res) => {
  const gadgetMode = isGadgetModeEnabled();
  const usbImgExists = fs.existsSync('/usb_drive.img');
  let usbFiles = [];
  if (usbImgExists) {
    try { usbFiles = getUsbFiles(); } catch (e) { usbFiles = ['(error)']; }
  }
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>PiSpot Node Control Panel</title>
      <style>
        body { font-family: sans-serif; background: #222; color: #eee; margin: 0; padding: 0; }
        .container { max-width: 700px; margin: 40px auto; background: #333; border-radius: 8px; padding: 2em; }
        h1 { color: #6cf; }
        button { padding: 0.5em 1.5em; margin: 0.5em 0; font-size: 1em; border-radius: 4px; border: none; background: #6cf; color: #222; cursor: pointer; }
        button:disabled { background: #888; }
        .info { margin: 1em 0; }
        .footer { margin-top: 2em; font-size: 0.9em; color: #aaa; }
        .files { background: #222; padding: 1em; border-radius: 6px; margin: 1em 0; }
        .console { background: #111; color: #0f0; font-family: monospace; padding: 1em; border-radius: 6px; min-height: 120px; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>PiSpot Node Control Panel</h1>
        <div class="info">
          <b>USB Gadget Mode:</b> <span>${gadgetMode ? 'Enabled' : 'Disabled'}</span><br>
          <b>USB Storage Image:</b> <span>${usbImgExists ? '/usb_drive.img present' : 'Not found'}</span>
        </div>
        <div class="files">
          <b>Files in USB Storage:</b><br>
          <ul>${usbFiles.map(f => `<li>${f}</li>`).join('')}</ul>
        </div>
        <form method="POST" action="/expand">
          <label>Expand USB Storage (MB):</label>
          <input type="number" name="size" min="1" max="51200" required>
          <button type="submit">Expand</button>
        </form>
        <form method="POST" action="/shrink">
          <label>Shrink USB Storage (MB):</label>
          <input type="number" name="size" min="1" max="51200" required>
          <button type="submit">Shrink</button>
        </form>
        <form method="POST" action="/shutdown">
          <button type="submit" style="background:#f66;">Shutdown Pi</button>
        </form>
        <h2>Console</h2>
        <form id="console-form" method="POST" action="/console">
          <input type="text" name="cmd" style="width:80%" placeholder="Enter command...">
          <button type="submit">Run</button>
        </form>
        <pre class="console" id="console-output"></pre>
        <div class="footer">
          PiSpot Node &copy; 2024
        </div>
        <script>
          document.getElementById('console-form').onsubmit = async function(e) {
            e.preventDefault();
            const cmd = this.cmd.value;
            const res = await fetch('/console', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({cmd})});
            const out = await res.text();
            document.getElementById('console-output').textContent = out;
          };
        </script>
      </div>
    </body>
    </html>
  `);
});

app.post('/expand', (req, res) => {
  const size = parseInt(req.body.size);
  exec(`sudo /workspaces/pi/pispot_node_server/expand_usb.sh ${size}`, (err, stdout, stderr) => {
    if (err) return res.send('Failed to expand: ' + stderr);
    res.redirect('/');
  });
});

app.post('/shrink', (req, res) => {
  const size = parseInt(req.body.size);
  exec(`sudo /workspaces/pi/pispot_node_server/shrink_usb.sh ${size}`, (err, stdout, stderr) => {
    if (err) return res.send('Failed to shrink: ' + stderr);
    res.redirect('/');
  });
});

app.post('/shutdown', (req, res) => {
  exec('sudo shutdown now', (err) => {
    if (err) {
      res.send('Failed to shutdown: ' + err);
    } else {
      res.send('Shutting down...');
    }
  });
});

app.post('/console', (req, res) => {
  let cmd = req.body.cmd;
  if (!cmd) return res.send('No command');
  exec(cmd, {timeout: 10000}, (err, stdout, stderr) => {
    if (err) return res.send(stderr || err.toString());
    res.send(stdout);
  });
});

app.listen(port, () => {
  console.log(`PiSpot Node Control Panel running at http://localhost:${port}/`);
});
EOF

# Copy expand/shrink scripts if they exist
if [ -f /workspaces/pi/expand_usb.sh ]; then
    sudo cp /workspaces/pi/expand_usb.sh "$APP_DIR/expand_usb.sh"
    sudo chmod +x "$APP_DIR/expand_usb.sh"
fi
if [ -f /workspaces/pi/shrink_usb.sh ]; then
    sudo cp /workspaces/pi/shrink_usb.sh "$APP_DIR/shrink_usb.sh"
    sudo chmod +x "$APP_DIR/shrink_usb.sh"
fi

cat <<EOM

Node.js PiSpot Control Panel setup complete!
To start the server, run:
cd "$APP_DIR" && sudo node server.js $PORT
Then visit: http://<your-pi-ip>:$PORT/
EOM
