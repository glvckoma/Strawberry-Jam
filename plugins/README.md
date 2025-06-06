# Strawberry Jam - Plugin Development Guide

This guide provides instructions for creating plugins with standardized UI components for Strawberry Jam.

## Using the Standardized UI Components

To ensure a consistent UI experience across all plugins, we've created standardized components for common UI elements like headers, minimize buttons, and close buttons.

### For New Plugins

1. Start with the template provided in `plugins/template/`:
   - Copy the `template` folder and rename it to your plugin name
   - Modify `index.html` and `index.js` to implement your plugin functionality

2. The template includes:
   - Standardized draggable header with minimize and close buttons
   - Proper content area with consistent styling
   - Required stylesheets and scripts

### For Existing Plugins

To update an existing plugin to use the standardized UI:

1. Add the required stylesheet and script references to your HTML:

```html
<!-- In the <head> section -->
<link href="../../assets/css/style.css" rel="stylesheet">
<script src="../../assets/javascript/plugin-utils.js"></script>
```

2. Replace your custom header with the standardized header:

```html
<!-- Standardized Draggable Header -->
<div class="jam-plugin-header">
  <span class="jam-plugin-title">Your Plugin Name</span>
  <div class="jam-plugin-controls">
    <button class="jam-plugin-minimize" aria-label="Minimize">
      <i class="fas fa-minus"></i>
    </button>
    <button class="jam-plugin-close" aria-label="Close">
      <i class="fas fa-times"></i>
    </button>
  </div>
</div>
```

3. Wrap your main content in a div with the standardized content class:

```html
<!-- Main Content Area -->
<div class="jam-plugin-content">
  <!-- Your plugin content goes here -->
</div>
```

4. Initialize the plugin UI functionality by adding this script at the end of your HTML:

```html
<!-- Initialize Standardized UI -->
<script>
  document.addEventListener('DOMContentLoaded', function() {
    // Initialize standard plugin UI behavior (minimize/close)
    initializePluginUI();
  });
</script>
```

## Standardized UI Features

The standardized UI components provide:

1. **Consistent Styling**: Headers, buttons, and other UI elements match the main application styling.

2. **Proper Window Controls**: The minimize button properly minimizes the window to the taskbar, and the close button closes the window.

3. **Proper Draggable Region**: The header serves as a draggable region for moving the plugin window.

4. **Cross-Plugin Consistency**: All plugins share the same look and feel for common UI elements.

## CSS Classes Reference

- `jam-plugin-header`: The main header container with draggable functionality
- `jam-plugin-title`: The plugin title styling
- `jam-plugin-controls`: Container for the control buttons
- `jam-plugin-minimize`: Minimize button styling
- `jam-plugin-close`: Close button styling
- `jam-plugin-content`: Main content area with proper scrolling

## Example

See `plugins/colors/index.html` for an example of a plugin that uses the standardized UI components.

## Best Practices

1. Use the standardized header for all plugins
2. Keep the overall styling consistent with the main application
3. Utilize the provided utility functions for behavior (minimize, close, etc.)
4. Ensure your plugin works well with standard window controls

For more information or assistance, please reach out to the Strawberry Jam development team. 