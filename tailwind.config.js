/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: '#050505',
        surface: 'rgba(20, 15, 10, 0.4)',
        surfaceBorder: 'rgba(255, 255, 255, 0.04)',
        primary: '#FF6B2C',
        primaryGlow: 'rgba(255, 107, 44, 0.5)',
        secondary: '#E85D04',
        success: '#10B981',
        danger: '#EF4444',
        textMain: '#F8FAFC',
        textMuted: '#94A3B8',
        accent: '#FF8C42'
      },
      fontFamily: {
        sans: ['Geist', 'Inter', 'sans-serif'],
        display: ['Outfit', 'sans-serif'],
      },
      animation: {
        'blob': 'blob 7s infinite',
        'fade-in-up': 'fadeInUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards',
        'glow-pulse': 'glowPulse 3s infinite',
        'text-glow-pulse': 'textGlowPulse 3s infinite',
      },
      keyframes: {
        blob: {
          '0%': { transform: 'translate(0px, 0px) scale(1)' },
          '33%': { transform: 'translate(30px, -50px) scale(1.1)' },
          '66%': { transform: 'translate(-20px, 20px) scale(0.9)' },
          '100%': { transform: 'translate(0px, 0px) scale(1)' },
        },
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        glowPulse: {
          '0%': { boxShadow: '0 0 15px rgba(255, 107, 44, 0.2)' },
          '50%': { boxShadow: '0 0 30px rgba(255, 107, 44, 0.5)' },
          '100%': { boxShadow: '0 0 15px rgba(255, 107, 44, 0.2)' },
        },
        textGlowPulse: {
          '0%': { filter: 'drop-shadow(0 0 10px rgba(255, 107, 44, 0.2))' },
          '50%': { filter: 'drop-shadow(0 0 25px rgba(255, 107, 44, 0.6))' },
          '100%': { filter: 'drop-shadow(0 0 10px rgba(255, 107, 44, 0.2))' },
        }
      },
      backgroundImage: {
        'glass-gradient': 'linear-gradient(135deg, rgba(255, 255, 255, 0.05) 0%, rgba(255, 255, 255, 0.01) 100%)',
        'hero-glow': 'radial-gradient(circle at 50% 50%, rgba(255, 107, 44, 0.15) 0%, transparent 50%)',
      }
    },
  },
  plugins: [],
}
