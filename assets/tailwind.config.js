const colors = require('tailwindcss/colors')

module.exports = {
  purge: [
    '../**/*.html.eex',
    '../**/*.html.leex',
    '../**/views/**/*.ex',
    '../**/live/**/*.ex',
    './js/**/*.js'
  ],
  variants: {},
  theme: {
    fontFamily: {
      sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Open Sans', 'Helvetica Neue', 'sans-serif']
    },
    extend: {
      colors: {
        lime: colors.lime
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
