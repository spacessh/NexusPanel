/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './resources/scripts/**/*.{ts,tsx}',
        './public/index.html',
    ],
    theme: {
        extend: {
            colors: {
                nexus: {
                    bg:      '#050a0e',
                    surface: '#0d1b24',
                    border:  '#1a3a4a',
                    green:   '#00ff88',
                    cyan:    '#00e5ff',
                    red:     '#ff4466',
                    yellow:  '#ffcc00',
                    purple:  '#9966ff',
                },
            },
            fontFamily: {
                mono: ['JetBrains Mono', 'Courier New', 'monospace'],
                sans: ['Inter', 'system-ui', 'sans-serif'],
            },
        },
    },
    plugins: [],
};
