import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        landing: resolve(__dirname, 'index.html'),
      },
    },
  },
  server: {
    port: 3000,
    open: '/index.html',
  },
  preview: {
    port: 3000,
    open: '/index.html',
  },
})
