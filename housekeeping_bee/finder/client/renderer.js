// UI Elements
const btnRetry = document.getElementById('btnRetry');
const btnAbort = document.getElementById('btnAbort');
const btnExit = document.getElementById('btnExit');
const btnClearLog = document.getElementById('btnClearLog');
const statusIcon = document.getElementById('statusIcon');
const statusText = document.getElementById('statusText');
const progressContainer = document.getElementById('progressContainer');
const devicesGrid = document.getElementById('devicesGrid');
const deviceCount = document.getElementById('deviceCount');
const logContent = document.getElementById('logContent');
const networkInterfaces = document.getElementById('networkInterfaces');
const platformBadge = document.getElementById('platformBadge');

// State
let isDiscovering = false;
let discoveredDevices = [];

// Check if electronAPI is available
if (!window.electronAPI) {
    console.error('❌ electronAPI not found! Preload script may not be loaded.');
    alert('Error: Application not properly initialized. Please restart the app.');
}

// Initialize
async function initialize() {
    try {
        // Load platform info
        if (window.electronAPI && window.electronAPI.getPlatformInfo) {
            const platformInfo = await window.electronAPI.getPlatformInfo();
            displayPlatformInfo(platformInfo);
        } else {
            displayPlatformInfo({
                platform: 'unknown',
                arch: 'unknown',
                hostname: 'N/A'
            });
        }

        // Load network interfaces
        if (window.electronAPI && window.electronAPI.getNetworkInterfaces) {
            const interfaces = await window.electronAPI.getNetworkInterfaces();
            displayNetworkInterfaces(interfaces);
        } else {
            networkInterfaces.innerHTML = '<p class="loading">Network info unavailable</p>';
        }

        // Setup event listeners
        setupEventListeners();

        // Auto-start discovery
        setTimeout(() => startDiscovery(), 500);
    } catch (error) {
        console.error('Initialization error:', error);
        addLog('⚠️ Initialization error: ' + error.message, 'warning');
    }
}

function displayPlatformInfo(info) {
    const platform = info.platform === 'darwin' ? '🍎 macOS' :
        info.platform === 'win32' ? '🪟 Windows' :
            '🐧 Linux';
    platformBadge.innerHTML = `${platform} | ${info.arch} `; // | ${info.hostname}
}

function displayNetworkInterfaces(interfaces) {
    if (interfaces.length === 0) {
        networkInterfaces.innerHTML = '<p class="loading">No active network interfaces found</p>';
        return;
    }

    networkInterfaces.innerHTML = '';

    // Separate by type
    const wifiInterfaces = interfaces.filter(i => i.isWiFi);
    const ethernetInterfaces = interfaces.filter(i => i.isEthernet);
    const vpnInterfaces = interfaces.filter(i => i.isVPN);
    const otherInterfaces = interfaces.filter(i => !i.isWiFi && !i.isEthernet && !i.isVPN);

    // Helper function to create interface card
    const createInterfaceCard = (iface, icon, color) => {
        const div = document.createElement('div');
        div.className = `network-item ${iface.isVPN ? 'vpn' : ''}`;
        div.style.borderLeft = `4px solid ${color}`;

        let vpnMaybe = '';

        if (iface.mac === '00:00:00:00:00:00' && iface.address.includes('10.')) {
            vpnMaybe = '<div style="font-size: 11px; color: #666; margin-bottom: 4px;">VPN is on</div>';
            div.className = `network-item vpn`;
        }

        div.innerHTML = `
            <div style="display: flex; justify-content: space-between; align-items: start;">
                <div style="flex: 1;">
                    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
                        <span style="font-size: 18px;">${icon}</span>
                        <strong style="font-size: 14px;">${iface.type}</strong>
                        ${iface.isVPN ? '<span style="background: #ffc107; color: #000; padding: 2px 8px; border-radius: 10px; font-size: 10px; font-weight: bold;">VPN</span>' : ''}
                    </div>
                    <div style="font-family: 'Consolas', monospace; color: #667eea; font-weight: 600; font-size: 13px; margin-bottom: 6px;">
                        ${iface.address} 
                    </div>
                    <div style="font-size: 11px; color: #666; margin-bottom: 4px;">
                        Interface: ${iface.name} 
                    </div>
                    ${vpnMaybe}
                </div>
            </div>
        `;

        return div;
    };

    // Add WiFi interfaces
    wifiInterfaces.forEach(iface => {
        networkInterfaces.appendChild(createInterfaceCard(iface, '📶', '#4CAF50'));
    });

    // Add Ethernet interfaces
    ethernetInterfaces.forEach(iface => {
        networkInterfaces.appendChild(createInterfaceCard(iface, '🔌', '#2196F3'));
    });

    // Add VPN interfaces (with warning)
    vpnInterfaces.forEach(iface => {
        networkInterfaces.appendChild(createInterfaceCard(iface, '🔒', '#FF9800'));
    });

    // Add other interfaces
    otherInterfaces.forEach(iface => {
        networkInterfaces.appendChild(createInterfaceCard(iface, '🌐', '#9E9E9E'));
    });

    // Add summary
    const summary = document.createElement('div');
    summary.style.cssText = 'margin-top: 10px; padding: 10px; background: rgba(102, 126, 234, 0.1); border-radius: 8px; font-size: 12px; color: #667eea; font-weight: 600;';
    const totalCount = interfaces.length;
    const types = [];
    if (wifiInterfaces.length > 0) types.push(`${wifiInterfaces.length} WiFi`);
    if (ethernetInterfaces.length > 0) types.push(`${ethernetInterfaces.length} LAN`);
    if (vpnInterfaces.length > 0) types.push(`${vpnInterfaces.length} VPN`);
    summary.textContent = `Total: ${totalCount} interface${totalCount > 1 ? 's' : ''} (${types.join(', ')})`;
    networkInterfaces.appendChild(summary);
}

function setupEventListeners() {
    btnRetry.addEventListener('click', startDiscovery);
    btnAbort.addEventListener('click', abortDiscovery);
    btnExit.addEventListener('click', () => window.close());
    btnClearLog.addEventListener('click', clearLog);

    // Setup IPC listeners
    window.electronAPI.onDeviceFound(handleDeviceFound);
    window.electronAPI.onDiscoveryLog(handleLog);
    window.electronAPI.onDiscoveryError(handleError);
    window.electronAPI.onDiscoveryComplete(handleDiscoveryComplete);
}

async function startDiscovery() {
    if (isDiscovering) {
        addLog('⚠️ Discovery already in progress...', 'warning');
        return;
    }

    // Load network interfaces
    if (window.electronAPI && window.electronAPI.getNetworkInterfaces) {
        const interfaces = await window.electronAPI.getNetworkInterfaces();
        displayNetworkInterfaces(interfaces);
    } else {
        networkInterfaces.innerHTML = '<p class="loading">Network info unavailable</p>';
    }

    isDiscovering = true;
    discoveredDevices = [];
    devicesGrid.innerHTML = '<div class="empty-state"><div class="empty-icon">🔍</div><p>Scanning for devices...</p></div>';
    deviceCount.textContent = '0';

    updateStatus('🔍', 'Discovering devices...', true);
    btnRetry.disabled = true;
    btnAbort.disabled = false;

    clearLog();
    addLog('========================================');
    addLog('UDP Discovery Started');
    addLog('========================================');
    addLog('Broadcasting to network...');
    addLog('Waiting for responses...\n');

    try {
        await window.electronAPI.startDiscovery({
            port: 9999,
            message: 'FIND_MY_BEE',
            timeout: 5000,
            broadcastAddress: '255.255.255.255'
        });
    } catch (error) {
        addLog(`❌ Discovery failed: ${error}`, 'error');
        updateStatus('❌', 'Discovery failed', false);
    }
}

async function abortDiscovery() {
    if (!isDiscovering) return;

    addLog('\n⏹ Aborting discovery...', 'warning');
    await window.electronAPI.abortDiscovery();

    isDiscovering = false;
    updateStatus('⏹', 'Discovery aborted', false);
    btnRetry.disabled = false;
    btnAbort.disabled = true;

    if (discoveredDevices.length === 0) {
        devicesGrid.innerHTML = '<div class="empty-state"><div class="empty-icon">⏹</div><p>Discovery aborted</p><p class="empty-hint">Click "Start Discovery" to try again</p></div>';
    }
}

function handleDeviceFound(device) {
    // Check for duplicates
    if (discoveredDevices.find(d => d.ip === device.ip)) {
        return;
    }

    discoveredDevices.push(device);
    addDeviceCard(device);
    deviceCount.textContent = discoveredDevices.length;
    logDeviceInfo(device);
}

function logDeviceInfo(device) {
    addLog('✅ Device Found!', 'success');
    addLog('========================================');
    addLog(`Hostname:        ${device.hostname}`);

    // Show WiFi and Ethernet separately
    if (device.interfaces) {
        if (device.interfaces.wifi) {
            addLog(`WiFi IP:         ${device.interfaces.wifi.ip} (${device.interfaces.wifi.name})`);
        }
        if (device.interfaces.ethernet) {
            addLog(`Ethernet IP:     ${device.interfaces.ethernet.ip} (${device.interfaces.ethernet.name})`);
        }
        if (!device.interfaces.wifi && !device.interfaces.ethernet) {
            addLog(`IP Address:      ${device.ip}`);
        }
    } else {
        // Fallback for old server response
        addLog(`IP Address:      ${device.ip}`);
        addLog(`Interface:       ${device.interface || 'N/A'}`);
    }

    addLog(`HTTP Port:       ${device.httpPort}`);
    addLog(`Platform:        ${device.platform || 'Unknown'}`);
    addLog(`Response from:   ${device.respondedFrom}:${device.respondedPort}`);
    addLog('========================================\n');
}

function addDeviceCard(device) {
    // Remove empty state if exists
    const emptyState = devicesGrid.querySelector('.empty-state');
    if (emptyState) {
        devicesGrid.innerHTML = '';
    }

    const card = document.createElement('div');
    card.className = `device-card ${device.hasSSL ? 'ssl' : ''}`;
    card.onclick = () => showDeviceDetails(device);

    const icon = device.hasSSL ? '🔒' : '📱';
    const platformIcon = device.platform === 'linux' ? '🐧' :
        device.platform === 'darwin' ? '🍎' :
            device.platform === 'win32' ? '🪟' : '💻';

    // Build IP display
    let ipDisplay = '';
    if (device.interfaces) {
        if (device.interfaces.wifi) {
            ipDisplay += `<div class="device-info-row">
                <span class="device-info-label">📶 WiFi:</span>
                <span class="device-info-value">${device.interfaces.wifi.ip}</span>
            </div>`;
        }
        if (device.interfaces.ethernet) {
            ipDisplay += `<div class="device-info-row">
                <span class="device-info-label">🔌 LAN:</span>
                <span class="device-info-value">${device.interfaces.ethernet.ip}</span>
            </div>`;
        }
        if (!device.interfaces.wifi && !device.interfaces.ethernet) {
            ipDisplay = `<div class="device-info-row">
                <span class="device-info-label">IP Address:</span>
                <span class="device-info-value">${device.ip}</span>
            </div>`;
        }
    } else {
        // Fallback for old server
        ipDisplay = `<div class="device-info-row">
            <span class="device-info-label">IP Address:</span>
            <span class="device-info-value">${device.ip}</span>
        </div>`;
    }

    // Add WiFi SSID if available
    let ssidDisplay = '';
    if (device.wifiSSID) {
        ssidDisplay = `<div class="device-info-row">
            <span class="device-info-label">📡 SSID:</span>
            <span class="device-info-value">${device.wifiSSID}</span>
        </div>`;
    }

    card.innerHTML = `
        <div class="device-header">
            <div class="device-name">${device.hostname}</div>
            <div class="device-badge">${icon}</div>
        </div>
        <div class="device-info">
            ${ipDisplay}
            ${ssidDisplay}
            <div class="device-info-row">
                <span class="device-info-label">HTTP:</span>
                <span class="device-info-value">${device.httpPort}</span>
            </div>
            ${device.httpsPort ? `
            <div class="device-info-row">
                <span class="device-info-label">HTTPS:</span>
                <span class="device-info-value">${device.httpsPort}</span>
            </div>
            ` : ''}
            <div class="device-info-row">
                <span class="device-info-label">Platform:</span>
                <span class="device-info-value">${platformIcon} ${device.platform || 'Unknown'}</span>
            </div>
        </div>
    `;

    devicesGrid.appendChild(card);
}

function showDeviceDetails(device) {
    // Create modal overlay
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.7);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 1000;
        animation: fadeIn 0.3s;
    `;

    const modalContent = document.createElement('div');
    modalContent.className = 'modal-content';
    modalContent.style.cssText = `
        background: white;
        border-radius: 20px;
        padding: 30px;
        max-width: 600px;
        width: 90%;
        max-height: 85vh;
        overflow-y: auto;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    `;

    // Build interface list
    let interfacesList = '';
    if (device.interfaces) {

        console.log('webapp port', device.webAppHttpPort, device.httpPort);

        if (device.interfaces.wifi) {
            const wifi = device.interfaces.wifi;
            interfacesList += `
                <div class="interface-item wifi">
                    <div class="interface-header">
                        <span class="interface-icon">📶</span>
                        <span class="interface-type">WiFi</span>
                    </div>
                    <div class="interface-details">
                        <div><strong>IP:</strong> ${wifi.ip}</div>
                        <div><strong>Interface:</strong> ${wifi.name}</div>
                        ${device.wifiSSID ? `<div><strong>SSID:</strong> ${device.wifiSSID}</div>` : ''}
                        <div class="interface-actions">
                            <button class="modal-btn" onclick="openURL('http://${wifi.ip}:${device.httpPort}')">Open Housekeeper Bee App</button>
                            <button class="modal-btn" onclick="openURL('http://${wifi.ip}:${device.adminHttpPort}')">Open Housekeeper Bee Admin App</button>
                        </div>
                    </div>
                </div>
            `;
        }
        if (device.interfaces.ethernet) {
            const eth = device.interfaces.ethernet;
            interfacesList += `
                <div class="interface-item ethernet">
                    <div class="interface-header">
                        <span class="interface-icon">🔌</span>
                        <span class="interface-type">Ethernet</span>
                    </div>
                    <div class="interface-details">
                        <div><strong>IP:</strong> ${eth.ip}</div>
                        <div><strong>Interface:</strong> ${eth.name}</div>
                        <div class="interface-actions">
                            <button class="modal-btn" onclick="openURL('http://${eth.ip}:${device.httpPort}')">Open Housekeeper Bee App</button>
                            <button class="modal-btn" onclick="openURL('http://${eth.ip}:${device.adminHttpPort}')">Open Housekeeper Bee Admin App</button>
                        </div>
                    </div>
                </div>
            `;
        }
    }

    modalContent.innerHTML = `
        <h2 style="margin-bottom: 20px; color: #333;">Device Details</h2>
        <div style="margin-bottom: 20px;">
            <h3 style="font-size: 18px; color: #667eea; margin-bottom: 10px;">${device.hasSSL ? '🔒' : '📱'} ${device.hostname}</h3>
            <div style="color: #666; font-size: 14px;">
                Platform: ${device.platform || 'Unknown'} 
            </div>
        </div>
        
        <div class="interfaces-container">
            <h4 style="margin-bottom: 15px; color: #555;">Network Interfaces:</h4>
            ${interfacesList}
        </div>
        
        <!-- WiFi Scan Section -->
        <div style="margin-top: 25px; padding: 20px; background: #f8f9fa; border-radius: 12px; display:${device.interfaces.ethernet ? 'block' : 'none'}; ">
            <h4 style="margin-bottom: 15px; color: #555;">🔧 WiFi Tools</h4>
            
            <!-- Session Token -->
            <div style="margin-bottom: 15px;">
                <div style="display: flex; gap: 10px; align-items: center; margin-bottom: 10px;">
                    <button id="btnGetToken" class="tool-btn" style="
                        padding: 10px 20px;
                        background: #2196f3;
                        color: white;
                        border: none;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 600;
                        cursor: pointer;
                        
                    ">🔑 Housekeeper Bee device WiFi setting</button>
                    <span id="tokenStatus" style="font-size: 12px; color: #666;"></span>
                </div>
                <div id="tokenDisplay" style="
                    display: none;
                    padding: 10px;
                    background: #fff;
                    border: 1px solid #ddd;
                    border-radius: 6px;
                    font-family: 'Consolas', monospace;
                    font-size: 11px;
                    word-break: break-all;
                    color: #333;
                "></div>
            </div>
        </div>
        
        <button id="modalCloseBtn" class="modal-close-btn" style="
            width: 100%;
            padding: 12px;
            margin-top: 20px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
        ">Close</button>
    `;

    modal.appendChild(modalContent);
    document.body.appendChild(modal);

    // Store session token
    let sessionToken = null;

    // Use LAN (Ethernet) IP and HTTPS port
    const targetIP = device.interfaces?.ethernet?.ip || device.interfaces?.wifi?.ip || device.ip;
    const targetPort = device.httpsPort || device.httpPort;
    const useSSL = device.httpsPort ? true : false;

    var baseURL = useSSL ?
        `https://${targetIP}:${targetPort}` :
        `http://${targetIP}:${targetPort}`;

    console.log(`Using baseURL: ${baseURL} (LAN IP: ${targetIP}, SSL Port: ${targetPort})`);

    // Button 1: Get Session Token
    document.getElementById('btnGetToken').addEventListener('click', async function () {
        const btn = this;
        btn.onclick = () => {
            const eth = device.interfaces.ethernet;
            openURL(`https://${eth.ip}:3443/`);
        }
    });


    // Close button event
    document.getElementById('modalCloseBtn').addEventListener('click', function (e) {
        e.stopPropagation();
        modal.remove();
    });

    // Close on background click
    modal.addEventListener('click', function (e) {
        if (e.target === modal) {
            modal.remove();
        }
    });

    // Prevent clicks inside modal content from closing
    modalContent.addEventListener('click', function (e) {
        //  e.stopPropagagation();
    });
}

// Make openURL global
window.openURL = function (url) {
    window.electronAPI.openUrl(url);
};

function handleLog(message) {
    addLog(message);
}

function handleError(error) {
    addLog(`❌ Error: ${error}`, 'error');
}

function handleDiscoveryComplete(devices) {
    isDiscovering = false;
    btnRetry.disabled = false;
    btnAbort.disabled = true;

    if (devices.length === 0) {
        updateStatus('⚠️', 'No devices found', false);
        addLog('\n⚠️ No devices found', 'warning');
        addLog('Make sure the server is running and on the same network!');
        devicesGrid.innerHTML = '<div class="empty-state"><div class="empty-icon">⚠️</div><p>No devices found</p><p class="empty-hint">Make sure devices are powered on and connected</p><p>Ensure the VPN service is disabled or paused!</p></div>';
    } else {
        updateStatus('✅', `Found ${devices.length} device(s)`, false);
        addLog(`\n✅ Discovery complete. Found ${devices.length} device(s)`, 'success');
    }
}

function updateStatus(icon, text, showProgress) {
    statusIcon.textContent = icon;
    statusText.textContent = text;

    if (showProgress) {
        progressContainer.classList.add('active');
    } else {
        progressContainer.classList.remove('active');
    }
}

function addLog(message, type = '') {
    const entry = document.createElement('p');
    entry.className = `log-entry ${type}`;
    entry.textContent = message;
    logContent.appendChild(entry);
    logContent.scrollTop = logContent.scrollHeight;
}

function clearLog() {
    logContent.innerHTML = '';
}

function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        addLog(`📋 Copied to clipboard: ${text}`, 'success');

        // Show temporary notification
        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(76, 175, 80, 0.95);
            color: white;
            padding: 20px 40px;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            z-index: 1001;
            animation: fadeIn 0.3s ease-out;
        `;
        notification.textContent = `✓ Copied: ${text}`;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.style.animation = 'fadeOut 0.3s ease-out';
            setTimeout(() => notification.remove(), 300);
        }, 2000);
    });
}

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeIn {
        from { opacity: 0; transform: translate(-50%, -50%) scale(0.8); }
        to { opacity: 1; transform: translate(-50%, -50%) scale(1); }
    }
    @keyframes fadeOut {
        from { opacity: 1; transform: translate(-50%, -50%) scale(1); }
        to { opacity: 0; transform: translate(-50%, -50%) scale(0.8); }
    }
    
    .modal-btn {
        padding: 6px 12px;
        border: none;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
        color: white;
    }
    
    .modal-btn:nth-child(1) {
        background: #2196f3;
    }
    
    .modal-btn:nth-child(2) {
        background: #4caf50;
    }
    
    .modal-btn:nth-child(3) {
        background: #9e9e9e;
    }
    
    .modal-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
    }
    
    .modal-close-btn:hover {
        background: #5568d3 !important;
    }
    
    .interfaces-container {
        margin: 20px 0;
    }
    
    .interface-item {
        background: #f8f9fa;
        border-radius: 12px;
        padding: 15px;
        margin-bottom: 15px;
        border-left: 4px solid #667eea;
    }
    
    .interface-item.wifi {
        border-left-color: #4caf50;
        background: #f1f8f4;
    }
    
    .interface-item.ethernet {
        border-left-color: #2196f3;
        background: #f0f7ff;
    }
    
    .interface-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 10px;
    }
    
    .interface-icon {
        font-size: 24px;
    }
    
    .interface-type {
        font-size: 16px;
        font-weight: 600;
        color: #333;
    }
    
    .interface-details {
        font-size: 14px;
        color: #555;
    }
    
    .interface-details > div {
        margin-bottom: 8px;
    }
    
    .interface-details strong {
        color: #667eea;
        margin-right: 5px;
    }
    
    .interface-actions {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
        margin-top: 12px;
    }
`;
document.head.appendChild(style);

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initialize);
} else {
    initialize();
}