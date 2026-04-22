import type { Config } from 'tailwindcss'

export default {
  content: [
    './index.html',
    './src/**/*.{vue,js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#b87333',
        secondary: '#e8d8cb',
        dark: '#1a2735',
        accent: '#22c55e',
        danger: '#ef4444',
        border: '#d4c4bb',
      },
    },
  },
  plugins: [],
} satisfies Config
