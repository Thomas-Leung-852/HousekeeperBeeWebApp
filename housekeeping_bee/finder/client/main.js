const { app, BrowserWindow, ipcMain, Menu, shell } = require('electron');
const dgram = require('dgram');
const path = require('path');
const os = require('os');
const https = require('https');

let mainWindow;

const template = [
    {
        label: 'File',
        submenu: [
            {
                label: 'Exit',
                click() {
                    app.quit();
                },
            },
        ],
    },
    {
        label: 'View',
        submenu: [
            {
                label: 'Reload',
                accelerator: 'CmdOrCtrl+R',
                click() {
                    mainWindow.reload(); // Standard reload
                },
            },
            // {
            //     label: 'Toggle Developer Tools',
            //     accelerator: process.platform === 'darwin' ? 'Cmd+Alt+I' : 'Ctrl+Shift+I',
            //     click() {
            //         mainWindow.webContents.toggleDevTools();
            //     },
            // },
        ],
    },
    {
        label: 'Help',
        submenu: [
            {
                label: 'VPN',
                click: async () => {
                     const helpWin = new BrowserWindow({
                        width: 800,
                        height: 600,
                        webPreferences: {
                        },
                        autoHideMenuBar: true,
                        icon: path.join(__dirname, 'icon.ico'),
                        parent: mainWindow, // Set the parent window
                        modal: true, // Make it a modal dialog
                        title: 'VPN setting',
                    });
                     helpWin.loadFile(path.join(__dirname, 'public', 'help_vpn.html'));
                }
            },
            {
                type: 'separator' // Adds a separator line
            },
            {
                label: 'About',
                click: () => {
                    const helpWin = new BrowserWindow({
                        width: 600,
                        height: 300,
                        webPreferences: {
                            //preload: path.join(__dirname, 'preload.js') // Optional
                        },
                        autoHideMenuBar: true,
                        parent: mainWindow, // Set the parent window
                        modal: true, // Make it a modal dialog
                        icon: path.join(__dirname, 'icon.ico'),
                        title: 'About',
                    }
                );

                    // Load the help file
                    helpWin.loadFile(path.join(__dirname, 'public', 'about.html'));
                }
            },
        ]
    }
];

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 900,
        height: 1000,
        minWidth: 700,
        minHeight: 500,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js')
        },
        icon: path.join(__dirname, 'icon.ico'),
        title: 'WiFi Setup Device Discovery',
        backgroundColor: '#667eea'
    });

    mainWindow.loadFile('index.html');

    // Open DevTools in development
    // mainWindow.webContents.openDevTools();

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

app.setName('Find My Bee');

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});

app.on('ready', () => {
    const menu = Menu.buildFromTemplate(template);
    Menu.setApplicationMenu(menu);
});

// ========================================
// IPC Handlers for UDP Discovery
// ========================================

let discoverySocket = null;
let discoveryTimeout = null;

ipcMain.handle('open-url', async (event, url) => { 
    try {
        console.log('Opening URL:', url);
        await shell.openExternal(url);
        return { success: true };
    } catch (error) {
        console.error('Error opening URL:', error);
        return { success: false, error: error.message };
    }
});

// Get network interfaces info
ipcMain.handle('get-network-interfaces', async () => {
    const interfaces = os.networkInterfaces();
    const result = [];

    for (let name in interfaces) {
        for (let iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                // Detect interface type
                const nameLower = name.toLowerCase();
                const isVPN = nameLower.includes('vpn') ||
                    nameLower.includes('tap') ||
                    nameLower.includes('tun') ||
                    nameLower.includes('utun');

                const isWiFi = nameLower.includes('wi-fi') ||
                    nameLower.includes('wifi') ||
                    nameLower.includes('wlan') ||
                    nameLower.includes('en0') ||
                    nameLower.includes('wlp');

                const isEthernet = nameLower.includes('eth') ||
                    nameLower.includes('en1') ||
                    nameLower.includes('en2') ||
                    nameLower.includes('lan') ||
                    nameLower.includes('enp');

                let type = 'Unknown';
                if (isVPN) type = 'VPN';
                else if (isWiFi) type = 'WiFi';
                else if (isEthernet) type = 'Ethernet';

                result.push({
                    name: name,
                    address: iface.address,
                    netmask: iface.netmask,
                    mac: iface.mac,
                    type: type,
                    isVPN: isVPN,
                    isWiFi: isWiFi,
                    isEthernet: isEthernet
                });
            }
        }
    }

    return result;
});


// Start UDP discovery
ipcMain.handle('start-discovery', async (event, options) => {
    return new Promise((resolve, reject) => {
        const {
            port = 9999,
            message = 'FIND_MY_BEE',
            timeout = 5000,
            broadcastAddress = '255.255.255.255'
        } = options;

        const devices = [];

        // Close existing socket if any
        if (discoverySocket) {
            discoverySocket.close();
        }

        // Clear existing timeout
        if (discoveryTimeout) {
            clearTimeout(discoveryTimeout);
        }

        // Create UDP socket
        discoverySocket = dgram.createSocket({ type: 'udp4', reuseAddr: true });

        // Handle errors
        discoverySocket.on('error', (err) => {
            event.sender.send('discovery-error', err.message);
            discoverySocket.close();
            discoverySocket = null;
            reject(err);
        });

        // Handle incoming messages
        discoverySocket.on('message', (msg, rinfo) => {
            try {
                const data = JSON.parse(msg.toString());
                data.respondedFrom = rinfo.address;
                data.respondedPort = rinfo.port;

                // Check for duplicates
                const exists = devices.find(d => d.ip === data.ip);
                if (!exists) {

                    //console.log(`data: ${msg.toString()}`);

                    devices.push(data);
                    event.sender.send('device-found', data);
                }
            } catch (error) {
                event.sender.send('discovery-log', `Invalid response from ${rinfo.address}: ${error.message}`);
            }
        });

        // Bind and send broadcast
        discoverySocket.bind(() => {
            discoverySocket.setBroadcast(true);

            const buffer = Buffer.from(message);

            discoverySocket.send(buffer, 0, buffer.length, port, broadcastAddress, (err) => {
                if (err) {
                    event.sender.send('discovery-error', `Broadcast failed: ${err.message}`);
                    reject(err);
                } else {
                    event.sender.send('discovery-log', `✓ Broadcast sent to ${broadcastAddress}:${port}`);
                }
            });
        });

        // Set timeout
        discoveryTimeout = setTimeout(() => {
            if (discoverySocket) {
                discoverySocket.close();
                discoverySocket = null;
            }

            event.sender.send('discovery-complete', devices);
            resolve(devices);
        }, timeout);
    });
});

// Abort discovery
ipcMain.handle('abort-discovery', async () => {
    if (discoverySocket) {
        discoverySocket.close();
        discoverySocket = null;
    }

    if (discoveryTimeout) {
        clearTimeout(discoveryTimeout);
        discoveryTimeout = null;
    }

    return { success: true };
});

// Get platform info
ipcMain.handle('get-platform-info', async () => {
    return {
        platform: process.platform,
        arch: process.arch,
        version: os.release(),
        hostname: os.hostname(),
        type: os.type()
    };
});