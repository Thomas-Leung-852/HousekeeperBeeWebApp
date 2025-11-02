const { contextBridge, ipcRenderer } = require('electron');


// Expose protected methods to renderer process
contextBridge.exposeInMainWorld('electronAPI', {
    // Discovery operations
    startDiscovery: (options) => {
        try {
            return ipcRenderer.invoke('start-discovery', options);
        } catch (error) {
            console.error('startDiscovery error:', error);
            return Promise.reject(error);
        }
    },

    abortDiscovery: () => {
        try {
            return ipcRenderer.invoke('abort-discovery');
        } catch (error) {
            console.error('abortDiscovery error:', error);
            return Promise.reject(error);
        }
    },

    // System info
    getNetworkInterfaces: () => {
        try {
            return ipcRenderer.invoke('get-network-interfaces');
        } catch (error) {
            console.error('getNetworkInterfaces error:', error);
            return Promise.resolve([]);
        }
    },

    getPlatformInfo: () => {
        try {
            return ipcRenderer.invoke('get-platform-info');
        } catch (error) {
            console.error('getPlatformInfo error:', error);
            return Promise.resolve({
                platform: process.platform,
                arch: process.arch,
                version: 'unknown',
                hostname: 'unknown',
                type: 'unknown'
            });
        }
    },

    openUrl: (url) => {
        try {
            return ipcRenderer.invoke('open-url', url);
        } catch (error) {
            console.error('open url error:', error);
            return Promise.resolve([]);
        }
    },

    // Event listeners
    onDeviceFound: (callback) => {
        const listener = (event, device) => callback(device);
        ipcRenderer.on('device-found', listener);
        return () => ipcRenderer.removeListener('device-found', listener);
    },

    onDiscoveryLog: (callback) => {
        const listener = (event, message) => callback(message);
        ipcRenderer.on('discovery-log', listener);
        return () => ipcRenderer.removeListener('discovery-log', listener);
    },

    onDiscoveryError: (callback) => {
        const listener = (event, error) => callback(error);
        ipcRenderer.on('discovery-error', listener);
        return () => ipcRenderer.removeListener('discovery-error', listener);
    },

    onDiscoveryComplete: (callback) => {
        const listener = (event, devices) => callback(devices);
        ipcRenderer.on('discovery-complete', listener);
        return () => ipcRenderer.removeListener('discovery-complete', listener);
    },

    // Remove listeners
    removeAllListeners: () => {
        ipcRenderer.removeAllListeners('device-found');
        ipcRenderer.removeAllListeners('discovery-log');
        ipcRenderer.removeAllListeners('discovery-error');
        ipcRenderer.removeAllListeners('discovery-complete');
    }
});

// Debug: Log that preload loaded successfully
console.log('✓ Preload script loaded successfully');
console.log('✓ electronAPI exposed to renderer');