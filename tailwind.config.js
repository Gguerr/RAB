/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        'wine': {
          'primary': '#722F37',
          'secondary': '#8B3A3A',
          'dark': '#5D2428',
          'light': '#A64B4B',
        },
        'lead': {
          'primary': '#4A4A4A',
          'light': '#6B6B6B',
          'dark': '#2F2F2F',
          'lighter': '#8A8A8A',
        },
        'background': {
          'primary': '#F5F3F4',
          'secondary': '#E8E5E6',
        }
      }
    },
  },
  plugins: [],
}


