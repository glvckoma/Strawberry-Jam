const path = require('path');
const { ipcRenderer } = require('electron');

exports.name = 'updatesModal';

exports.render = async function (app, data = {}) {
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
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70 backdrop-blur-sm" id="updatesModalOverlay">
            <div class="bg-primary-bg rounded-xl shadow-2xl max-w-4xl w-full mx-4 max-h-[85vh] overflow-hidden transform">
                <!-- Header -->
                <div class="px-6 py-4 bg-secondary-bg border-b border-sidebar-border">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-3">
                            <div class="w-10 h-10 bg-highlight-green/20 rounded-full flex items-center justify-center">
                                <span class="text-highlight-green text-lg font-bold">🎉</span>
                            </div>
                            <div>
                                <h2 class="text-xl font-semibold text-text-primary">What's New</h2>
                                <p class="text-sidebar-text text-sm">Version ${versionData.version} • ${versionData.releaseDate}</p>
                            </div>
                        </div>
                        <div class="flex items-center space-x-2">
                            ${availableVersions.length > 1 ? `
                                <select id="versionSelector" class="bg-tertiary-bg border border-sidebar-border rounded px-3 py-1 text-text-primary text-sm focus:outline-none focus:border-highlight-green transition-colors">
                                    ${availableVersions.map(v => `
                                        <option value="${v}" ${v === targetVersion ? 'selected' : ''}>${v}</option>
                                    `).join('')}
                                </select>
                            ` : ''}
                            <button class="modal-close-button-std text-sidebar-text hover:text-text-primary transition-colors duration-200 transform rounded-full p-2" id="closeModalBtn" aria-label="Close">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Content -->
                <div class="flex h-full max-h-[calc(85vh-140px)]">
                    <!-- Tab Navigation -->
                    <div class="w-48 bg-secondary-bg border-r border-sidebar-border p-4 overflow-y-auto">
                        <div class="space-y-2">
                            ${Object.entries(versionData.categories).filter(([key, items]) => items.length > 0).map(([key, items]) => {
                                const tabInfo = getTabInfo(key);
                                return `
                                    <button class="tab-button w-full text-left px-3 py-2 rounded-lg text-sidebar-text hover:text-text-primary hover:bg-tertiary-bg transition-colors flex items-center space-x-2" data-tab="${key}">
                                        <span>${tabInfo.icon}</span>
                                        <span class="text-sm">${tabInfo.label}</span>
                                        <span class="ml-auto text-xs bg-highlight-green/20 text-highlight-green px-2 py-1 rounded-full">${items.length}</span>
                                    </button>
                                `;
                            }).join('')}
                        </div>
                    </div>

                    <!-- Tab Content -->
                    <div class="flex-1 bg-primary-bg overflow-y-auto p-6">
                        <div id="tabContent" class="tab-content animate-fade-in-up">
                            ${generateTabContent(versionData.categories)}
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <div class="px-6 py-4 bg-secondary-bg border-t border-sidebar-border">
                    <div class="flex justify-between items-center">
                        <div class="text-sm text-sidebar-text flex items-center">
                            <i class="fas fa-lightbulb mr-2 text-highlight-green"></i>
                            <span>Access via Settings → Application Updates → Check for Updates</span>
                        </div>
                        <div class="flex space-x-3">
                            <button id="markAsRead" class="px-4 py-2 bg-highlight-green/20 text-highlight-green hover:bg-highlight-green/30 rounded-lg transition-colors text-sm font-medium">
                                <i class="fas fa-check mr-2"></i>Mark as Read
                            </button>
                            <button id="closeModalBtn2" class="px-4 py-2 bg-tertiary-bg text-sidebar-text hover:bg-sidebar-hover hover:text-text-primary rounded-lg transition-colors text-sm font-medium">
                                <i class="fas fa-times mr-2"></i>Close
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `);

    // Tab switching logic
    const categoryKeys = Object.keys(versionData.categories);
    
    let activeTab = categoryKeys.find(key => versionData.categories[key] && versionData.categories[key].length > 0) || 'features';
    
    // Safety check - if no valid tab found, use features and ensure it exists
    if (!versionData.categories[activeTab]) {
        versionData.categories.features = [{
            icon: '🎉',
            title: 'No Updates Available',
            description: 'There are currently no updates to display.',
            priority: 'major'
        }];
        activeTab = 'features';
    }
    
    function switchTab(tabName) {
        activeTab = tabName;
        
        // Safety check - ensure the tab exists
        if (!versionData.categories[tabName]) {
            tabName = 'features';
        }
        
        // Update tab buttons with fruit-themed styling and smooth transitions
        $modal.find('.tab-button').removeClass('text-text-primary bg-tertiary-bg').addClass('text-sidebar-text');
        $modal.find(`[data-tab="${tabName}"]`).removeClass('text-sidebar-text').addClass('text-text-primary bg-tertiary-bg');
        
        // Smooth content transition with staggered fade animations
        const $content = $modal.find('#tabContent');
        
        // Fade out current content
        $content.css({
            'opacity': '1',
            'transform': 'translateY(0px)',
            'transition': 'opacity 0.2s ease-out, transform 0.2s ease-out'
        }).animate({
            'opacity': '0',
            'transform': 'translateY(-10px)'
        }, {
            duration: 200,
            step: function(now, fx) {
                if (fx.prop === 'transform') {
                    $(this).css('transform', `translateY(${now}px)`);
                }
            },
            complete: function() {
                // Update content after fade out
                try {
                    $content.html(generateTabContentForCategory(tabName, versionData.categories[tabName]));
                } catch (error) {
                    console.error('Error updating tab content:', error);
                    $content.html('<div class="text-center py-8 text-sidebar-text">Error loading content</div>');
                }
                
                // Fade in new content with staggered animation
                $content.css({
                    'opacity': '0',
                    'transform': 'translateY(10px)'
                }).animate({
                    'opacity': '1',
                    'transform': 'translateY(0px)'
                }, {
                    duration: 300,
                    step: function(now, fx) {
                        if (fx.prop === 'transform') {
                            $(this).css('transform', `translateY(${now}px)`);
                        }
                    },
                    complete: function() {
                        // Add staggered animation to content items
                        $content.find('.space-y-4 > div').each(function(index) {
                            const $item = $(this);
                            $item.css({
                                'opacity': '0',
                                'transform': 'translateY(20px)',
                                'transition': 'opacity 0.3s ease-out, transform 0.3s ease-out'
                            });
                            
                            setTimeout(() => {
                                $item.css({
                                    'opacity': '1',
                                    'transform': 'translateY(0px)'
                                });
                            }, index * 50); // Stagger by 50ms per item
                        });
                    }
                });
            }
        });
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
        
        // Add smooth transition for version change
        const $modalContent = $modal.find('.transform');
        
        $modalContent.css({
            'opacity': '1',
            'transform': 'scale(1) rotateY(0deg)',
            'transition': 'opacity 0.3s ease-out, transform 0.3s ease-out'
        }).animate({
            'opacity': '0',
            'transform': 'scale(0.95) rotateY(-5deg)'
        }, {
            duration: 300,
            step: function(now, fx) {
                if (fx.prop === 'transform') {
                    if (fx.prop === 'transform') {
                        const scale = fx.now;
                        $(this).css('transform', `scale(${scale}) rotateY(-5deg)`);
                    }
                }
            },
            complete: function() {
                // Reload modal with new version after fade out
                app.modals.show('updatesModal', '#modalContainer', { version: selectedVersion });
            }
        });
    });

    $modal.find('#closeModalBtn, #closeModalBtn2, #updatesModalOverlay').click(function(e) {
        if (e.target === this) {
            // Enhanced smooth exit animation
            $modal.find('.transform').css({
                'opacity': '1',
                'transform': 'scale(1) translateY(0px)',
                'filter': 'blur(0px)',
                'transition': 'opacity 0.3s ease-in-out, transform 0.3s ease-in-out, filter 0.2s ease-in-out'
            }).animate({
                'opacity': '0',
                'transform': 'scale(0.9) translateY(-20px)',
                'filter': 'blur(4px)'
            }, {
                duration: 300,
                step: function(now, fx) {
                    if (fx.prop === 'transform') {
                        $(this).css('transform', `scale(${now}) translateY(-20px)`);
                    } else if (fx.prop === 'filter') {
                        $(this).css('filter', `blur(4px)`);
                    }
                },
                complete: function() {
                    app.modals.close();
                }
            });
            
            // Fade out backdrop with slight delay
            setTimeout(() => {
                $modal.animate({ 'opacity': '0' }, 250);
            }, 50);
        }
    });

    $modal.find('#markAsRead').click(async function() {
        try {
            await ipcRenderer.invoke('set-setting', 'lastSeenVersion', targetVersion);
            showToast($modal, 'Updates marked as read!', 'success');
            
            // Delay close to show toast
            setTimeout(() => {
                $modal.find('#closeModalBtn').click();
            }, 1500);
        } catch (error) {
            console.error('Failed to mark as read:', error);
            showToast($modal, 'Failed to mark as read', 'error');
        }
    });

    // Enhanced entrance animation with app.css patterns
    $modal.css({ 'opacity': '0' });
    $modal.find('.transform').css({
        'opacity': '0',
        'transform': 'scale(0.9) translateY(20px)',
        'filter': 'blur(4px)'
    });

    setTimeout(() => {
        $modal.css({
            'opacity': '1',
            'transition': 'opacity 0.3s ease-out'
        });
        
        $modal.find('.transform').css({
            'opacity': '1',
            'transform': 'scale(1) translateY(0px)',
            'filter': 'blur(0px)',
            'transition': 'opacity 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94), transform 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94), filter 0.3s ease-out'
        });
        
        // Staggered animation for header elements
        setTimeout(() => {
            $modal.find('.tab-button').each(function(index) {
                const $tab = $(this);
                $tab.css({
                    'opacity': '0',
                    'transform': 'translateX(-20px)',
                    'transition': 'opacity 0.3s ease-out, transform 0.3s ease-out'
                });
                
                setTimeout(() => {
                    $tab.css({
                        'opacity': '1',
                        'transform': 'translateX(0px)'
                    });
                }, index * 50);
            });
            
            // Animate initial content
            $modal.find('#tabContent .space-y-4 > div').each(function(index) {
                const $item = $(this);
                $item.css({
                    'opacity': '0',
                    'transform': 'translateY(30px)',
                    'transition': 'opacity 0.3s ease-out, transform 0.3s ease-out'
                });
                
                setTimeout(() => {
                    $item.css({
                        'opacity': '1',
                        'transform': 'translateY(0px)'
                    });
                }, 200 + (index * 75)); // Start after modal animation + stagger
            });
        }, 100);
    }, 10);

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
        return '<div class="text-center py-8 text-sidebar-text">No items in this category</div>';
    }

    const isShortcuts = categoryKey === 'shortcuts';
    const isCommands = categoryKey === 'commands';

    return `
        <div class="space-y-4">
            ${items.map(item => `
                <div class="rounded-lg p-4 bg-secondary-bg border border-sidebar-border hover:border-highlight-green/30 hover:bg-tertiary-bg transition-all duration-200">
                    <div class="flex items-start space-x-3">
                        <div class="w-8 h-8 bg-highlight-green/20 rounded-full flex items-center justify-center flex-shrink-0">
                            <span class="text-sm">${item.icon}</span>
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="flex items-center justify-between">
                                <h3 class="font-semibold text-text-primary">${item.title}</h3>
                                ${item.priority ? `<span class="text-xs px-2 py-1 rounded-full ${getPriorityClass(item.priority)}">${item.priority}</span>` : ''}
                            </div>
                            <p class="text-sidebar-text text-sm mt-1">${item.description}</p>
                            ${isShortcuts && item.keys ? `
                                <div class="mt-2 flex items-center space-x-1">
                                    ${item.keys.map(key => `
                                        <kbd class="px-2 py-1 text-xs bg-tertiary-bg border border-sidebar-border rounded font-mono text-text-primary">${key}</kbd>
                                    `).join(' + ')}
                                </div>
                            ` : ''}
                            ${isCommands && item.command ? `
                                <div class="mt-2">
                                    <code class="px-2 py-1 text-xs bg-tertiary-bg border border-sidebar-border rounded font-mono text-highlight-green">${item.command}</code>
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
            return 'bg-blue-500/20 text-blue-400';
        case 'fix':
            return 'bg-red-500/20 text-red-400';
        default:
            return 'bg-sidebar-text/20 text-sidebar-text';
    }
}

/**
 * Show a toast notification positioned relative to the modal
 * @param {jQuery} $modal - The modal element for positioning context
 * @param {string} message - The message to show
 * @param {string} type - The type of notification (success, error, warning)
 */
function showToast($modal, message, type = 'success') {
    const colors = {
        success: 'bg-highlight-green text-white',
        error: 'bg-red-500 text-white',
        warning: 'bg-yellow-500 text-black'
    };

    const icons = {
        success: 'fas fa-check-circle',
        error: 'fas fa-exclamation-circle',
        warning: 'fas fa-exclamation-triangle'
    };

    const toastId = `updates-toast-${Date.now()}`;
    const toast = $(`
        <div id="${toastId}" class="fixed top-4 right-4 px-4 py-2 rounded-lg shadow-xl z-[100000] text-sm font-medium ${colors[type] || colors.success}">
            <i class="${icons[type]} mr-2"></i>${message}
        </div>
    `);
    
    // Enhanced toast animation
    toast.css({
        'opacity': '0',
        'transform': 'translateY(-20px) scale(0.9)',
        'filter': 'blur(2px)',
        'transition': 'opacity 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94), transform 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94), filter 0.2s ease-out'
    });
    
    $('body').append(toast);
    
    // Animate in
    setTimeout(() => {
        toast.css({
            'opacity': '1',
            'transform': 'translateY(0px) scale(1)',
            'filter': 'blur(0px)'
        });
    }, 10);

    setTimeout(() => {
        toast.css({
            'opacity': '0',
            'transform': 'translateY(-10px) scale(0.95)',
            'filter': 'blur(1px)',
            'transition': 'opacity 0.25s ease-in-out, transform 0.25s ease-in-out, filter 0.2s ease-in-out'
        });
        setTimeout(() => toast.remove(), 250);
    }, 3000);
}

exports.close = function (app) {
    // Optional cleanup when modal is closed
};