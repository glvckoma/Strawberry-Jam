const path = require('path');
const { ipcRenderer } = require('electron');

exports.name = 'updatesModal';

exports.render = async function (app, data = {}) {
    console.log('[DEBUG] updatesModal.render called with data:', data);
    const { version = null, showHistory = false } = data;
    
    let updatesData;
    try {
        const dataPath = path.join(__dirname, '../../../../data/updates-data.json');
        const rawData = await ipcRenderer.invoke('read-file', dataPath);
        updatesData = JSON.parse(rawData);
    } catch (error) {
        console.error('Failed to load updates data:', error);
        updatesData = {};
    }

    const targetVersion = version || Object.keys(updatesData).find(v => updatesData[v].isLatest) || Object.keys(updatesData)[0];
    const versionData = updatesData[targetVersion];
    
    if (!versionData) {
        return null;
    }

    const availableVersions = Object.keys(updatesData).sort((a, b) => {
        const aVersion = a.split('.').map(Number);
        const bVersion = b.split('.').map(Number);
        for (let i = 0; i < Math.max(aVersion.length, bVersion.length); i++) {
            const aPart = aVersion[i] || 0;
            const bPart = bVersion[i] || 0;
            if (aPart !== bPart) return bPart - aPart;
        }
        return 0;
    });

    const $modal = $(`
        <div class="flex items-center justify-center min-h-screen p-4" style="z-index: 9999;">
            <div class="fixed inset-0 bg-black bg-opacity-70 backdrop-blur-sm transition-opacity" id="modalBackdrop" style="z-index: 9000;"></div>
            
            <div class="relative rounded-lg shadow-xl max-w-4xl w-full max-h-[85vh] overflow-hidden" style="z-index: 9100; background-color: rgb(28, 30, 38); border: 1px solid rgb(58, 61, 77);">
                <!-- Header -->
                <div class="px-6 py-4 border-b" style="background-color: rgb(58, 61, 77); border-color: rgb(22, 23, 31);">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-3">
                            <div class="w-10 h-10 bg-highlight-green/20 rounded-full flex items-center justify-center">
                                <span class="text-highlight-green text-lg font-bold">🎉</span>
                            </div>
                            <div>
                                <h2 class="text-xl font-bold text-text-primary">What's New</h2>
                                <p class="text-gray-400 text-sm">Version ${versionData.version} • ${versionData.releaseDate}</p>
                            </div>
                        </div>
                        <div class="flex items-center space-x-2">
                            ${availableVersions.length > 1 ? `
                                <select id="versionSelector" class="bg-tertiary-bg border border-sidebar-border rounded px-3 py-1 text-text-primary text-sm">
                                    ${availableVersions.map(v => `
                                        <option value="${v}" ${v === targetVersion ? 'selected' : ''}>${v}</option>
                                    `).join('')}
                                </select>
                            ` : ''}
                        </div>
                    </div>
                </div>

                <!-- Content -->
                <div class="flex h-full max-h-[calc(85vh-80px)]">
                    <!-- Tab Navigation -->
                    <div class="w-48 border-r p-4 overflow-y-auto" style="background-color: rgb(44, 46, 52); border-color: rgb(58, 61, 77);">
                        <div class="space-y-2">
                            ${Object.entries(versionData.categories).filter(([key, items]) => items.length > 0).map(([key, items]) => {
                                const tabInfo = getTabInfo(key);
                                return `
                                    <button class="tab-button w-full text-left px-3 py-2 rounded-lg text-gray-400 hover:text-text-primary hover:bg-secondary-bg transition-colors flex items-center space-x-2" data-tab="${key}">
                                        <span>${tabInfo.icon}</span>
                                        <span class="text-sm">${tabInfo.label}</span>
                                        <span class="ml-auto text-xs bg-highlight-green/20 text-highlight-green px-2 py-1 rounded-full">${items.length}</span>
                                    </button>
                                `;
                            }).join('')}
                        </div>
                    </div>

                    <!-- Tab Content -->
                    <div class="flex-1 overflow-y-auto p-6">
                        <div id="tabContent">
                            ${generateTabContent(versionData.categories)}
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <div class="px-6 py-4 border-t" style="background-color: rgb(58, 61, 77); border-color: rgb(22, 23, 31);">
                    <div class="flex justify-between items-center mb-3">
                        <div class="text-sm text-gray-400">
                            <span>💡 Access via Settings → Application Updates → Check for Updates</span>
                        </div>
                        <div class="flex space-x-3">
                            <button id="markAsRead" class="px-4 py-2 bg-highlight-green/20 text-highlight-green hover:bg-highlight-green/30 rounded-lg transition-colors text-sm">
                                Mark as Read
                            </button>
                            <button id="closeModalBtn" class="px-4 py-2 bg-gray-600/20 text-gray-400 hover:bg-gray-600/30 rounded-lg transition-colors text-sm">
                                Close
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `);

    // Tab switching logic
    let activeTab = Object.keys(versionData.categories).find(key => versionData.categories[key].length > 0) || 'features';
    
    function switchTab(tabName) {
        activeTab = tabName;
        
        // Update tab buttons with smooth transition
        $modal.find('.tab-button').removeClass('text-text-primary').addClass('text-gray-400').css('background-color', 'transparent');
        $modal.find(`[data-tab="${tabName}"]`).removeClass('text-gray-400').addClass('text-text-primary').css('background-color', 'rgb(28, 30, 38)');
        
        // Smooth content transition
        const $content = $modal.find('#tabContent');
        $content.css({
            'opacity': '0',
            'transform': 'translateY(10px)',
            'transition': 'opacity 0.2s ease-out, transform 0.2s ease-out'
        });
        
        setTimeout(() => {
            $content.html(generateTabContentForCategory(tabName, versionData.categories[tabName]));
            $content.css({
                'opacity': '1',
                'transform': 'translateY(0)'
            });
        }, 200);
    }

    // Initialize first tab
    switchTab(activeTab);

    // Event listeners
    $modal.find('.tab-button').click(function() {
        const tabName = $(this).data('tab');
        switchTab(tabName);
    });

    $modal.find('#versionSelector').change(function() {
        const selectedVersion = $(this).val();
        app.modals.show('updatesModal', '#modalContainer', { version: selectedVersion });
    });

    $modal.find('#closeModal, #closeModalBtn, #modalBackdrop').click(function(e) {
        if (e.target === this) {
            app.modals.close('updatesModal');
        }
    });

    $modal.find('#markAsRead').click(async function() {
        try {
            await ipcRenderer.invoke('set-setting', 'lastSeenVersion', targetVersion);
            showGlobalToast('Updates marked as read!', 'success');
            app.modals.close('updatesModal');
        } catch (error) {
            console.error('Failed to mark as read:', error);
            showGlobalToast('Failed to mark as read', 'error');
        }
    });

    // Entrance animation
    $modal.css({
        'opacity': '0',
        'transform': 'scale(0.95)'
    });

    setTimeout(() => {
        $modal.css({
            'opacity': '1',
            'transform': 'scale(1)',
            'transition': 'opacity 0.2s ease-out, transform 0.2s ease-out'
        });
    }, 10);

    console.log('[DEBUG] updatesModal.render complete, returning modal');
    return $modal;
};

function getTabInfo(key) {
    const tabMap = {
        'features': { icon: '🎉', label: 'New Features' },
        'improvements': { icon: '⚡', label: 'Improvements' },
        'fixes': { icon: '🐛', label: 'Bug Fixes' },
        'shortcuts': { icon: '⌨️', label: 'Shortcuts' },
        'commands': { icon: '💻', label: 'Commands' },
        'messages': { icon: '📢', label: 'Messages' }
    };
    return tabMap[key] || { icon: '📝', label: key.charAt(0).toUpperCase() + key.slice(1) };
}

function generateTabContent(categories) {
    const firstCategory = Object.keys(categories).find(key => categories[key].length > 0);
    return generateTabContentForCategory(firstCategory, categories[firstCategory]);
}

function generateTabContentForCategory(categoryKey, items) {
    if (!items || items.length === 0) {
        return '<div class="text-center py-8 text-gray-400">No items in this category</div>';
    }

    const isShortcuts = categoryKey === 'shortcuts';
    const isCommands = categoryKey === 'commands';

    return `
        <div class="space-y-4">
            ${items.map(item => `
                <div class="rounded-lg p-4 border hover:border-highlight-green/30 transition-colors" style="background-color: rgb(44, 46, 52); border-color: rgb(58, 61, 77);">
                    <div class="flex items-start space-x-3">
                        <div class="w-8 h-8 bg-highlight-green/20 rounded-full flex items-center justify-center flex-shrink-0">
                            <span class="text-sm">${item.icon}</span>
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center justify-between">
                                <h3 class="font-semibold text-text-primary">${item.title}</h3>
                                ${item.priority ? `<span class="text-xs px-2 py-1 rounded-full ${getPriorityClass(item.priority)}">${item.priority}</span>` : ''}
                            </div>
                            <p class="text-gray-400 text-sm mt-1">${item.description}</p>
                            ${isShortcuts && item.keys ? `
                                <div class="mt-2 flex items-center space-x-1">
                                    ${item.keys.map(key => `
                                        <kbd class="px-2 py-1 text-xs border rounded font-mono" style="background-color: rgb(28, 30, 38); border-color: rgb(58, 61, 77);">${key}</kbd>
                                    `).join(' + ')}
                                </div>
                            ` : ''}
                            ${isCommands && item.command ? `
                                <div class="mt-2">
                                    <code class="px-2 py-1 text-xs border rounded font-mono text-highlight-green" style="background-color: rgb(28, 30, 38); border-color: rgb(58, 61, 77);">${item.command}</code>
                                </div>
                            ` : ''}
                        </div>
                    </div>
                </div>
            `).join('')}
        </div>
    `;
}

function getPriorityClass(priority) {
    switch (priority) {
        case 'major':
            return 'bg-highlight-green/20 text-highlight-green';
        case 'enhancement':
            return 'bg-highlight-blue/20 text-highlight-blue';
        case 'fix':
            return 'bg-error-red/20 text-error-red';
        default:
            return 'bg-gray-600/20 text-gray-400';
    }
}

exports.close = function (app) {
    // Optional cleanup when modal is closed
};