const $ = require('jquery');

module.exports = {
  name: 'linksModal',
  render: (application) => {
    // Create modal overlay
    const $modal = $('<div>', {
      class: 'fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70 backdrop-blur-sm',
      id: 'linksModal'
    });

    // Create modal content container
    const $content = $('<div>', {
      class: 'bg-primary-bg rounded-xl shadow-2xl max-w-sm w-full mx-4 overflow-hidden transform'
    });

    // Modal header
    const $header = $('<div>', {
      class: 'px-6 py-4 bg-secondary-bg border-b border-sidebar-border flex items-center justify-between'
    });

    const $title = $('<h3>', {
      class: 'text-lg font-semibold text-text-primary flex items-center',
      html: '<i class="fas fa-link mr-2"></i> Quick Links'
    });

    const $closeButton = $('<button>', {
      type: 'button',
      class: 'text-gray-400 hover:bg-error-red hover:text-white transition-colors p-1 rounded-md',
      'aria-label': 'Close'
    }).append(
      $('<i>', { class: 'fas fa-times' })
    ).on('click', () => {
      // Add exit animation
      $content.css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.25s ease-in-out, transform 0.25s ease-in-out'
      }).animate({
        'opacity': '0',
        'transform': 'scale(0.95)'
      }, {
        duration: 250,
        step: function(now, fx) {
          if (fx.prop === 'transform') {
            $(this).css('transform', `scale(${now})`);
          }
        },
        complete: function() {
          application.modals.close();
        }
      });
      
      // Fade out backdrop
      $modal.animate({
        'opacity': '0'
      }, 250);
    });

    $header.append($title, $closeButton);

    // Modal body with links
    const $body = $('<div>', {
      class: 'p-6' // Add padding to the body
    });

    const $linksContainer = $('<div>', {
        class: 'flex justify-around items-center space-x-4' // Use justify-around for spacing
    });

    // Define links data
    const links = [
      { url: 'https://discord.gg/a2y6bZnhB3', label: 'Discord', icon: 'fab fa-discord', color: 'hover:text-indigo-400' },
      { url: 'https://github.com/glvckoma/Strawberry-Jam', label: 'GitHub', icon: 'fab fa-github', color: 'hover:text-highlight-green' },
      { url: 'https://github.com/glvckoma/Berry-Breach', label: 'Berry Breach', color: 'hover:text-purple-500', svg: '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-bottom:4px;"><path d="M22 5V2l-5.89 5.89"/><circle cx="16.6" cy="15.89" r="3"/><circle cx="8.11" cy="7.4" r="3"/><circle cx="12.35" cy="11.65" r="3"/><circle cx="13.91" cy="5.85" r="3"/><circle cx="18.15" cy="10.09" r="3"/><circle cx="6.56" cy="13.2" r="3"/><circle cx="10.8" cy="17.44" r="3"/><circle cx="5" cy="19" r="3"/></svg>' },
      { url: 'https://github.com/glvckoma/AJC-Price-Checker', label: 'AJC Price Checker', icon: 'fas fa-dollar-sign', color: 'hover:text-blue-400' },
      { url: 'https://chromewebstore.google.com/detail/winkwink-ace-your-studies/pbafopkihldjbcececbibklapleogfdf?authuser=1&hl=en', label: 'WinkWink', icon: 'fas fa-graduation-cap', color: 'hover:text-yellow-500' }
    ];

    links.forEach(link => {
      const $iconEl = link.svg
        ? $(link.svg)
        : $('<i>', { class: `${link.icon} text-2xl mb-1` });
      const $link = $('<a>', {
        href: '#',
        class: `text-sidebar-text ${link.color} p-3 rounded-lg hover:bg-tertiary-bg transition-colors flex flex-col items-center text-center`,
        onclick: `jam.application.open('${link.url}'); return false;`,
        'aria-label': link.label,
        'data-tooltip': link.label
      }).append($iconEl);
      $linksContainer.append($link);
    });

    $body.append($linksContainer);

    // Assemble modal
    $content.append($header, $body);
    $modal.append($content);

    // Entrance animation - with consistent 0.25s timing
    $content.css({
      'opacity': '0',
      'transform': 'scale(0.95)'
    });
    
    $modal.css({
      'opacity': '0'
    });

    setTimeout(() => {
      $content.css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.25s ease-out, transform 0.25s ease-out'
      });
      
      $modal.css({
        'opacity': '1',
        'transition': 'opacity 0.25s ease-out'
      });
    }, 10);

    // Handle backdrop click to close
    $modal.on('click', function(e) {
      if (e.target === this) {
        $closeButton.click();
      }
    });

    return $modal;
  }
};
