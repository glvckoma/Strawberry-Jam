"use strict";

// --- Tester Bridge Script ---
// This script loads *before* LoginScreen.js and defines placeholder functions
// globally. The actual ES modules will load later and register their
// implementations with this bridge.

(function() {
    console.log('[TesterBridge] Initializing bridge...');

    let _realInitTesterUI = null;
    let _realSetupTesterIPCListeners = null;
    // Remove variables for UI functions no longer handled by bridge listener
    // let _realRenderTesterAccountList = null;
    // let _realUpdateTesterSummary = null;
    let _shadowRootForUI = null;
    let _ipcListenersSetupCalled = false;

    // Placeholder for UI initialization
    window.initTesterUI = function(shadowRoot) {
        console.log('[TesterBridge] Placeholder initTesterUI called.');
        _shadowRootForUI = shadowRoot; // Store shadowRoot for later
        if (_realInitTesterUI) {
            console.log('[TesterBridge] Real initTesterUI available, calling now.');
            _realInitTesterUI(shadowRoot);
        } else {
            console.log('[TesterBridge] Real initTesterUI not yet registered.');
        }
    };

    // Placeholder for IPC listener setup
    window.setupTesterIPCListeners = function() {
        console.log('[TesterBridge] Placeholder setupTesterIPCListeners called.');
        _ipcListenersSetupCalled = true; // Mark that setup was requested
        if (_realSetupTesterIPCListeners) {
            console.log('[TesterBridge] Real setupTesterIPCListeners available, calling now.');
            _realSetupTesterIPCListeners();
        } else {
            console.log('[TesterBridge] Real setupTesterIPCListeners not yet registered.');
        }
    };

    // Registration function for the real UI initializer
    window.registerInitTesterUI = function(realFunction) {
        console.log('[TesterBridge] Registering real initTesterUI.');
        _realInitTesterUI = realFunction;
        // If initTesterUI was already called with a shadowRoot, call the real one now
        if (_shadowRootForUI) {
            console.log('[TesterBridge] Calling registered initTesterUI immediately with stored shadowRoot.');
            _realInitTesterUI(_shadowRootForUI);
        }
    };

    // REMOVE Placeholder for List Render function
    // window.renderTesterAccountList = function(forceFullRender = false) { ... };

    // REMOVE Placeholder for Summary Update function
    // window.updateTesterSummary = function() { ... };

    // Registration function for the real UI initializer
    window.registerSetupTesterIPCListeners = function(realFunction) {
        console.log('[TesterBridge] Registering real setupTesterIPCListeners.');
        _realSetupTesterIPCListeners = realFunction;
        // If setupTesterIPCListeners was already called, call the real one now
        if (_ipcListenersSetupCalled) {
            console.log('[TesterBridge] Calling registered setupTesterIPCListeners immediately.');
            _realSetupTesterIPCListeners();
        }
    };

    // REMOVE Registration function for the real List Render function
    // window.registerRenderTesterAccountList = function(realFunction) { ... };

     // REMOVE Registration function for the real Summary Update function
    // window.registerUpdateTesterSummary = function(realFunction) { ... };

    // REMOVE loginSucceeded Listener - No longer needed in bridge
    // if (window.ipc) { ... }
    // --- End loginSucceeded Listener ---

    // Placeholder for tester status update function
    window.updateTesterAccountStatus = (index, status, error = null) => console.warn(`updateTesterAccountStatus placeholder called for index ${index}, status ${status}`);
    window.registerUpdateTesterAccountStatus = (fn) => { window.updateTesterAccountStatus = fn; };

    console.log('[TesterBridge] Bridge initialized.');
})();
