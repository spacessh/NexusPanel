import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        alias: {
            '@': path.resolve(__dirname, 'resources/scripts'),
        },
    },
    root: '.',
    publicDir: false,
    build: {
        outDir: 'public/build',
        manifest: true,
        rollupOptions: {
            input: 'index.html',
        },
    },
    server: {
        port: 3000,
        host: '0.0.0.0',
    },
});
