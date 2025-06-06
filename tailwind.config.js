/** @type {import('tailwindcss').Config} */
module.exports = {
  theme: {
    extend: {
      colors: {
        'primary-bg': '#121212',
        'secondary-bg': '#121212',
        'tertiary-bg': '#3A3D4D',
        'text-primary': '#C3C3C3',
        'highlight-yellow': '#f0b429',
        'highlight-green': '#38b000',
        'sidebar-bg': '#121212',
        'sidebar-border': '#3A3D4D',
        'custom-pink': '#F10048',
        'sidebar-text': '#C3C3C3',
        'sidebar-hover': '#2C2E34',
        'error-red': '#FF4D4F',
        'custom-blue': '#7785cc',
        'peachy-beige': '#FCE8C7'
      },
      animation: {
        'fade-in-up': 'fadeInUp 0.25s ease-out forwards',
        'fade-in-down': 'fadeInDown 0.25s ease-out forwards',
        'fade-in-left': 'fadeInLeft 0.25s ease-out forwards',
        'fade-in-right': 'fadeInRight 0.25s ease-out forwards',
        'scale-in': 'scaleIn 0.25s ease-out forwards',
        'scale-out': 'scaleOut 0.25s ease-out forwards',
      },
      keyframes: {
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        fadeInDown: {
          '0%': { opacity: '0', transform: 'translateY(-10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        fadeInLeft: {
          '0%': { opacity: '0', transform: 'translateX(10px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        fadeInRight: {
          '0%': { opacity: '0', transform: 'translateX(-10px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        scaleIn: {
          '0%': { opacity: '0', transform: 'scale(0.95)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
        scaleOut: {
          '0%': { opacity: '1', transform: 'scale(1)' },
          '100%': { opacity: '0', transform: 'scale(0.95)' },
        },
      },
      transitionProperty: {
        'width': 'width',
        'height': 'height',
        'spacing': 'margin, padding',
      },
      transitionDuration: {
        '400': '400ms',
      },
      transitionTimingFunction: {
        'soft-spring': 'cubic-bezier(0.3, 2, 0.4, 0.9)',
      },
    }
  },
  content: [
    './src/**/*.{html,js}',
    './plugins/*.js',
    './plugins/*/!(node_modules)/**/*.js'
  ],
  darkMode: 'class',
  plugins: [],
}
