// Design system color tokens
export const colors = {
  // Primary
  copper: '#b87333',
  navy: '#1a2735',
  cream: '#e8d8cb',
  coral: '#ff6b35',

  // Secondary (grays)
  gray: {
    900: '#0f1419',
    800: '#1a2735',
    700: '#2d3e52',
    600: '#4a5f78',
    500: '#6b7f99',
    400: '#8fa1b8',
    300: '#b3c1d4',
    200: '#d6dce6',
    100: '#eef0f6',
    50: '#f7f8fc',
  },

  // Semantic
  success: '#22c55e',
  error: '#ef4444',
  warning: '#f59e0b',
  info: '#3b82f6',
}

// Gradients
export const gradients = {
  copperToCoral: 'linear-gradient(135deg, #b87333, #ff6b35)',
  statGlow: 'linear-gradient(180deg, rgba(184, 115, 51, 0.1), transparent)',
}

// Shadow presets
export const shadows = {
  dynamic: '0 4px 12px rgba(26, 39, 53, 0.08)',
  dynamicHover: '0 12px 24px rgba(26, 39, 53, 0.12)',
}

// Animation durations (ms)
export const durations = {
  fast: 200,
  normal: 300,
  slow: 400,
  slower: 600,
}
