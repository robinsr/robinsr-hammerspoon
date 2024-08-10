const getSafeList = () => {
  const colorVariants = [ 'primary', 'secondary', 'accent', 'neutral', 'info', 'base', 'success', 'warning', 'error' ];
  const screenSizes = ['sm', 'md', 'lg', 'xl', '2xl'];
  const btnStates = ['active', 'disabled'];
  const btnVariants = ['ghost', 'link', 'outline'];
  const btnSizes = ['xs', 'sm', 'md', 'lg'];
  const btnShapes = ['circle', 'square'];
  const btnWidths = ['wide', 'block'];
  const btnAll = [ ...btnStates, ...btnVariants, ...btnSizes, ...btnShapes, ...btnWidths, ...colorVariants, ];

  // Prevent purging of classes that match these patterns
  // Many of these are applied conditionally depending on state (eg form validation state)
  return Object.values({
    scale: new RegExp('^scale-'),
    inputColorVariants: new RegExp(`^input-(${colorVariants.join('|')})`),
    textColorVariants: new RegExp(`^text-(${colorVariants.join('|')})-content`),
    bgColorVariants: new RegExp(`^bg-(${colorVariants.join('|')})`),
    btnAllVariants: new RegExp(`^btn-(${btnAll.join('|')})`),
    roundedEdges: new RegExp(/rounded-?(?:r|l|t|b|tr|tl|br|bl)*-?(?:none|sm|md|lg|full)$/),
    responsiveBtnSizes: new RegExp(`^(${screenSizes.join('|')}):btn-(${btnSizes.join('|')})`),
  }).map((item) => (item instanceof RegExp ? { pattern: item } : item));
}

/** @type {import('tailwindcss').Config} */
module.exports = {
  safelist: getSafeList(),
  content: ["./../templates/**/*.{view,html,js}"],
  theme: {
    patterns: {
      opacities: {
        100: "1",
        80: ".80",
        60: ".60",
        40: ".40",
        20: ".20",
        10: ".10",
        5: ".05",
      },
      sizes: {
        1: "0.25rem",
        2: "0.5rem",
        4: "1rem",
        6: "1.5rem",
        8: "2rem",
        16: "4rem",
        20: "5rem",
        24: "6rem",
        32: "8rem",
      }
    },
    extend: {},
  },
  plugins: [
    require('daisyui'),
    require('tailwindcss-bg-patterns'),
    require('@tailwindcss/forms'),
  ],
  daisyui: {
    themes: [
      {
        light: {
          ...require("daisyui/src/theming/themes")["corporate"],
          "--rounded-box": "0",
        },
        dark: {
          ...require("daisyui/src/theming/themes")["business"],
          "--rounded-box": "0",
        },
      },
    ],
    darkTheme: "dark", // name of one of the included themes for dark mode
    base: true, // applies background color and foreground color for root element by default
    styled: true, // include daisyUI colors and design decisions for all components
    utils: true, // adds responsive and modifier utility classes
    prefix: "", // prefix for daisyUI classnames (components, modifiers and responsive class names. Not colors)
    logs: true, // Shows info about daisyUI version and used config in the console when building your CSS
    themeRoot: ":root", // The element that receives theme color CSS variables
  }
}

