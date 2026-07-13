import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@orivastra/ui', '@orivastra/utils', '@orivastra/types'],
  images: {
    formats: ['image/avif', 'image/webp'],
  },
  experimental: {
    optimizePackageImports: ['lucide-react', '@orivastra/ui'],
  },
};

export default nextConfig;
