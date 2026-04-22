import type { Config } from 'tailwindcss'

// Tailwind v4: la mayoría de configuración va en src/styles/globals.css con @theme
// Este archivo es minimal, solo define content

export default {
  content: [
    './index.html',
    './src/**/*.{vue,js,ts,jsx,tsx}',
  ],
} satisfies Config
