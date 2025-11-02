const express = require('express');
const https = require('https');
const http = require('http');
const fs = require('fs');
const { exec } = require('child_process');
const dgram = require('dgram');
const os = require('os');
const crypto = require('crypto');
const cors = require('cors');
const multer = require('multer'); // For handling multipart/form-data
const upload = multer(); // Initialize multer

const app = express();
const HTTP_PORT = 3000;
const HTTPS_PORT = 3443;
const UDP_PORT = 9999;

app.set('view engine', 'ejs');
app.set('views', './views');

app.use(cors());
app.use(express.json());
app.use(express.static('.'));

// ========================================
// Security Setup
// ========================================

// Generate session tokens for authentication
const activeSessions = new Map();

function generateSessionToken() {
    return crypto.randomBytes(32).toString('hex');
}

function validateSession(req, res, next) {
    const token = req.headers['x-session-token'];

    if (!token || !activeSessions.has(token)) {
        return res.status(401).json({
            success: false,
            error: 'Unauthorized: Invalid or missing session token'
        });
    }

    // Extend session
    activeSessions.set(token, Date.now());
    next();
}

// Clean expired sessions (older than 30 minutes)
setInterval(() => {
    const now = Date.now();
    const timeout = 30 * 60 * 1000; // 30 minutes

    for (let [token, timestamp] of activeSessions) {
        if (now - timestamp > timeout) {
            activeSessions.delete(token);
        }
    }
}, 5 * 60 * 1000); // Check every 5 minutes

// ========================================
// Generate Self-Signed Certificate
// ========================================

function generateCertificate() {
    const certPath = './certs/server.crt';
    const keyPath = './certs/server.key';

    // Check if certificate exists
    if (fs.existsSync(certPath) && fs.existsSync(keyPath)) {
        console.log('[SSL] Using existing certificate');
        return {
            cert: fs.readFileSync(certPath),
            key: fs.readFileSync(keyPath)
        };
    }

    // Create certs directory
    if (!fs.existsSync('./certs')) {
        fs.mkdirSync('./certs');
    }

    console.log('[SSL] Generating self-signed certificate...');

    // Generate certificate (requires openssl)
    const cmd = `openssl req -x509 -newkey rsa:4096 -keyout ${keyPath} -out ${certPath} -days 3650 -nodes -subj "/CN=wifi-setup"`;

    try {
        require('child_process').execSync(cmd);
        console.log('[SSL] Certificate generated successfully');

        return {
            cert: fs.readFileSync(certPath),
            key: fs.readFileSync(keyPath)
        };
    } catch (error) {
        console.error('[SSL] Failed to generate certificate:', error.message);
        console.log('[SSL] Falling back to HTTP only mode');
        return null;
    }
}

// ========================================
// Helper Functions - UPDATED
// ========================================

// Get ALL network interfaces (LAN + WiFi + Others)
function getAllNetworkInterfaces() {
    const interfaces = os.networkInterfaces();
    const result = [];

    for (let name in interfaces) {
        for (let iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                // Detect interface type
                const nameLower = name.toLowerCase();

                const isWiFi = nameLower.includes('wi-fi') ||
                    nameLower.includes('wifi') ||
                    nameLower.includes('wlan') ||
                    nameLower.includes('wlp') ||
                    (nameLower === 'en0' && os.platform() === 'darwin'); // macOS WiFi

                const isEthernet = nameLower.includes('eth') ||
                    nameLower.includes('enp') ||
                    nameLower.includes('eno') ||
                    nameLower.includes('ens') ||
                    (nameLower.startsWith('en') && !isWiFi && os.platform() === 'darwin'); // macOS Ethernet

                const isVPN = nameLower.includes('vpn') ||
                    nameLower.includes('tap') ||
                    nameLower.includes('tun') ||
                    nameLower.includes('utun');

                let type = 'Unknown';
                if (isVPN) type = 'VPN';
                else if (isWiFi) type = 'WiFi';
                else if (isEthernet) type = 'Ethernet';

                result.push({
                    name: name,
                    ip: iface.address,
                    netmask: iface.netmask,
                    mac: iface.mac,
                    type: type,
                    isWiFi: isWiFi,
                    isEthernet: isEthernet,
                    isVPN: isVPN
                });
            }
        }
    }

    return result;
}

// Get primary private IP (prefers non-VPN, then WiFi, then Ethernet)
function getPrivateIP() {
    const allInterfaces = getAllNetworkInterfaces();

    // Filter out VPN
    const nonVPN = allInterfaces.filter(i => !i.isVPN);

    if (nonVPN.length === 0) {
        // Only VPN available
        return allInterfaces[0] || { interface: 'unknown', ip: '127.0.0.1', type: 'Unknown' };
    }

    // Prefer WiFi, then Ethernet
    const wifi = nonVPN.find(i => i.isWiFi);
    if (wifi) {
        return { interface: wifi.name, ip: wifi.ip, type: wifi.type };
    }

    const ethernet = nonVPN.find(i => i.isEthernet);
    if (ethernet) {
        return { interface: ethernet.name, ip: ethernet.ip, type: ethernet.type };
    }

    // Return first available
    return { interface: nonVPN[0].name, ip: nonVPN[0].ip, type: nonVPN[0].type };
}

// Get WiFi interface specifically
function getWiFiInterface() {
    const allInterfaces = getAllNetworkInterfaces();
    return allInterfaces.find(i => i.isWiFi) || null;
}

// Get Ethernet/LAN interface specifically
function getEthernetInterface() {
    const allInterfaces = getAllNetworkInterfaces();
    return allInterfaces.find(i => i.isEthernet) || null;
}

function execPromise(command) {
    return new Promise((resolve, reject) => {
        exec(command, (error, stdout, stderr) => {
            if (error) {
                reject({ error, stderr, stdout });
            } else {
                resolve({ stdout, stderr });
            }
        });
    });
}

async function scanWiFiNetworks() {
    try {
        const { stdout } = await execPromise('nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list');
        const networks = stdout.trim().split('\n').map(line => {
            const [inUse, ssid, signal, security] = line.split(':');
            return { inUse, ssid, signal: parseInt(signal), security };
        }).filter(n => n.ssid);

        const unique = {};
        networks.forEach(n => {
            if (!unique[n.ssid] || unique[n.ssid].signal < n.signal) {
                unique[n.ssid] = n;
            }
        });

        networks.forEach(n => {
            if (unique[n.ssid] && n.inUse === '*') {
                unique[n.ssid].inUse = '*';
            }
        });

        return Object.values(unique).sort((a, b) => b.signal - a.signal);
    } catch (error) {
        console.error('Error scanning WiFi:', error);
        return [];
    }
}

async function connectToWiFi(ssid, password) {
    try {

        const hb_pwd = process.env.HOUSEKEEPER_BEE_PWD_SUDO;

        console.log(`[WiFi] Attempting to connect to: ${ssid}`);

        try {
            await execPromise(`echo "${hb_pwd}" | sudo -S nmcli connection delete "${ssid}"`);
        } catch (e) {
            // Ignore if doesn't exist
        }

        const cmd = `echo "${hb_pwd}" | sudo -S nmcli device wifi connect "${ssid}" password "${password}" &>/dev/null `;

        const { stdout } = await execPromise(cmd);

        console.log('[WiFi] Connection successful:', stdout);

        // Wait for IP assignment
        for (let i = 0; i < 20; i++) {
            await new Promise(resolve => setTimeout(resolve, 500));
            const wifiInfo = getWiFiInterface();
            if (wifiInfo && wifiInfo.ip && wifiInfo.ip !== '127.0.0.1') {
                return wifiInfo;
            }
        }

        // throw new Error('Connected but no IP address assigned');
    } catch (error) {
        console.error('[WiFi] Connection failed:', error);
        throw error;
    }

    return null;
}

// Legacy function - kept for compatibility
function getWiFiConnectionInfo() {
    const wifiInterface = getWiFiInterface();
    if (wifiInterface) {
        return {
            interface: wifiInterface.name,
            ip: wifiInterface.ip,
            netmask: wifiInterface.netmask,
            mac: wifiInterface.mac
        };
    }
    return { interface: null, ip: null };
}

// ========================================
// UDP Broadcast Discovery - UPDATED
// ========================================

const udpServer = dgram.createSocket('udp4');

udpServer.on('message', (msg, rinfo) => {
    const message = msg.toString().trim();

    if (message === 'FIND_MY_BEE') {
        // Load ports info
        webAppHttpPort = null;
        webAppHttpsPort = null;
        adminAppHttpPort = null;
        adminAppHttpsPort = null;

        try {
            const data = fs.readFileSync('./ports.json', 'utf8');
            const jsonData = JSON.parse(data);

            webAppHttpPort = jsonData.webapp_http_port;
            webAppHttpsPort = jsonData.webapp_https_port;
            adminAppHttpPort = jsonData.admin_http_port;
            adminAppHttpsPort = jsonData.admin_https_port;

        } catch (error) {
            console.error('Error reading or parsing JSON:', error);
        }

        //
        console.log(`[UDP] Discovery request from ${rinfo.address}:${rinfo.port}`);

        const allInterfaces = getAllNetworkInterfaces();
        const primaryIP = getPrivateIP();
        const wifiInterface = getWiFiInterface();
        const ethernetInterface = getEthernetInterface();

        const response = JSON.stringify({
            // Primary IP (for backward compatibility)
            ip: primaryIP.ip,
            interface: primaryIP.interface,

            // Detailed interface information
            interfaces: {
                wifi: wifiInterface ? {
                    ip: wifiInterface.ip,
                    name: wifiInterface.name,
                    type: wifiInterface.type
                } : null,
                ethernet: ethernetInterface ? {
                    ip: ethernetInterface.ip,
                    name: ethernetInterface.name,
                    type: ethernetInterface.type
                } : null,
                all: allInterfaces.map(i => ({
                    ip: i.ip,
                    name: i.name,
                    type: i.type
                }))
            },

            hostname: os.hostname(),
            httpPort: webAppHttpPort,
            httpsPort: webAppHttpsPort,
            adminHttpPort: adminAppHttpPort,
            adminHttpsPort: adminAppHttpsPort,  // RFU
            udpPort: UDP_PORT,
            timestamp: Date.now(),
            hasSSL: sslCredentials !== null,
            platform: os.platform()
        });

        udpServer.send(response, rinfo.port, rinfo.address, (err) => {
            if (!err) {
                console.log(`[UDP] Sent discovery response to ${rinfo.address}`);
                console.log(`[UDP] Response includes: WiFi=${wifiInterface ? wifiInterface.ip : 'N/A'}, LAN=${ethernetInterface ? ethernetInterface.ip : 'N/A'}`);
            }
        });
    }
});

udpServer.bind(UDP_PORT);

// ========================================
// HTTP API Endpoints - UPDATED
// ========================================

// Initialize session (public endpoint)
app.post('/api/auth/init', (req, res) => {
    const token = generateSessionToken();
    activeSessions.set(token, Date.now());

    console.log(`[Auth] New session created: ${token.substring(0, 8)}...`);

    res.json({
        success: true,
        sessionToken: token,
        expiresIn: 1800 // 30 minutes
    });
});

// Get network status (public endpoint) - UPDATED
app.get('/api/network-status', (req, res) => {
    const allInterfaces = getAllNetworkInterfaces();
    const wifiInterface = getWiFiInterface();
    const ethernetInterface = getEthernetInterface();
    const primaryIP = getPrivateIP();

    res.json({
        primary: primaryIP,
        wifi: wifiInterface,
        ethernet: ethernetInterface,
        all: allInterfaces,
        hostname: os.hostname()
    });
});

// Scan WiFi networks (requires session)
app.get('/api/wifi/scan', validateSession, async (req, res) => {
    try {
        console.log('[API] Scanning WiFi networks...');
        const networks = await scanWiFiNetworks();
        res.json({
            success: true,
            networks: networks,
            count: networks.length
        });
    } catch (error) {
        console.error('[API] WiFi scan error:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

// Connect to WiFi (requires session)
app.post('/api/wifi/connect', validateSession, upload.none(), async (req, res) => {

    const { cmd, ssid, password } = req.body;

    if (cmd === 'add') {
        if (!ssid || !password) {
            return res.status(400).json({
                success: false,
                error: 'SSID and password are required'
            });
        }

        console.log(`[API] WiFi connection request for: ${ssid}`);
        console.log(`[Security] Request using ${req.secure ? 'HTTPS' : 'HTTP'}`);

        // Warn if using HTTP
        if (!req.secure) {
            console.warn('[Security] WARNING: Password transmitted over unencrypted HTTP!');
        }

        try {
            const wifiInfo = await connectToWiFi(ssid, password);

            // if(!wifiInfo){
            // res.json({
            //     success: true,
            //     message: 'Successfully connected to WiFi',
            //     wifi: {
            //         ssid: ssid,
            //         ip: wifiInfo.ip,
            //         interface: wifiInfo.name,
            //         netmask: wifiInfo.netmask
            //     }
            // });

            res.status(200).json({
                success: true,
                error: '',
                details: 'connected to wifi'
            });

            const cmd2 = `echo "${process.env.HOUSEKEEPER_BEE_PWD_SUDO}" | sudo -S reboot &>/dev/null `;
            await execPromise(cmd2);

            //console.log(`[WiFi] Successfully connected. New IP: ${wifiInfo.ip}`);




            //}
            //else{
            //     res.status(200).json({
            //         success: false,
            //         error: 'Failed to connect to WiFi',
            //         details: ''
            //     });     
            // }
        } catch (error) {
            console.log(`[WiFi] connection failure.`);
            res.status(200).json({
                success: false,
                error: 'Failed to connect to WiFi',
                details: error.stderr || error.stdout
            });

        }


    } else if (cmd === 'del') {
        //do disconnection
        try {
            const { stdout } = await execPromise(`echo "${process.env.HOUSEKEEPER_BEE_PWD_SUDO}" | sudo -S nmcli connection delete "${ssid}"`);

            res.status(200).json({
                success: true,
                error: 'disconnected to WiFi',
                details: ''
            });
        } catch (e) {
            // Ignore if doesn't exist
            res.status(200).json({
                success: false,
                error: e.message || 'Failed to disconnect to WiFi',
                details: e.stderr || e.stdout
            });
        }
    }
});

// Ping endpoint (public)
app.get('/api/ping', (req, res) => {
    res.json({
        success: true,
        message: 'Server is reachable',
        timestamp: Date.now(),
        ip: getPrivateIP().ip,
        secure: req.secure
    });
});

app.get('/', async (req, res) => {

    const sessionToken = generateSessionToken();
    const wifi = getWiFiInterface();
    const ssids = await scanWiFiNetworks();

    activeSessions.set(sessionToken, Date.now());
    var ssidName = 'N/A';

    if (wifi != null) {
        ssidName = wifi.name;
    }

    ssids.sort((a, b) => b.signal - a.signal);

    var connectedSSID = '';

    ssids.forEach(ssid => {
        if (ssid.inUse === '*') { connectedSSID = ssid.ssid }
    });

    res.render('index', { activeTab: 'edit', ssid_name: ssidName, ssids, connected_ssid: connectedSSID, session_token: sessionToken }); // Renders views/inputForm.ejs
});

// ========================================
// Start Servers - UPDATED
// ========================================

const sslCredentials = generateCertificate();
const allInterfaces = getAllNetworkInterfaces();
const wifiInterface = getWiFiInterface();
const ethernetInterface = getEthernetInterface();

// Start HTTP server
http.createServer(app).listen(HTTP_PORT, () => {
    console.log('\n========================================');
    console.log('WiFi Setup Server Started');
    console.log('========================================');

    if (wifiInterface) {
        console.log(`[HTTP] WiFi:     http://${wifiInterface.ip}:${HTTP_PORT}`);
    }
    if (ethernetInterface) {
        console.log(`[HTTP] Ethernet: http://${ethernetInterface.ip}:${HTTP_PORT}`);
    }
    if (!wifiInterface && !ethernetInterface && allInterfaces.length > 0) {
        console.log(`[HTTP] Server:   http://${allInterfaces[0].ip}:${HTTP_PORT}`);
    }
});

// Start HTTPS server if certificate available
if (sslCredentials) {
    https.createServer(sslCredentials, app).listen(HTTPS_PORT, () => {
        console.log(`[HTTPS] Secure server enabled on port ${HTTPS_PORT}`);
        if (wifiInterface) {
            console.log(`[HTTPS] WiFi:     https://${wifiInterface.ip}:${HTTPS_PORT}`);
        }
        if (ethernetInterface) {
            console.log(`[HTTPS] Ethernet: https://${ethernetInterface.ip}:${HTTPS_PORT}`);
        }
        console.log('[HTTPS] Note: You\'ll see a certificate warning (self-signed)');
    });
} else {
    console.log('[HTTPS] Not available - running HTTP only');
    console.log('[WARNING] Passwords will be transmitted unencrypted!');
}

console.log(`[UDP] Discovery port: ${UDP_PORT}`);
console.log(`[Network] Active Interfaces:`);
if (wifiInterface) {
    console.log(`  WiFi:     ${wifiInterface.name} (${wifiInterface.ip})`);
}
if (ethernetInterface) {
    console.log(`  Ethernet: ${ethernetInterface.name} (${ethernetInterface.ip})`);
}
if (allInterfaces.length > 0) {
    const others = allInterfaces.filter(i => !i.isWiFi && !i.isEthernet);
    others.forEach(i => {
        console.log(`  ${i.type}: ${i.name} (${i.ip})`);
    });
}
console.log('========================================');
console.log('\nSecurity Features:');
console.log('✓ Session token authentication');
console.log('✓ HTTPS encryption (if available)');
console.log('✓ Session timeout (30 minutes)');
console.log('✓ Protected API endpoints');
console.log('========================================\n');
