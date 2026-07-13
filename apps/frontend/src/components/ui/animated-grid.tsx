'use client';

import { useEffect, useRef } from 'react';

export function AnimatedGrid() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const resize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };
    resize();
    window.addEventListener('resize', resize);

    const cols = 40;
    const cellSize = canvas.width / cols;
    const rows = Math.ceil(canvas.height / cellSize);

    const dots: { x: number; y: number; baseOpacity: number; phase: number }[] = [];
    for (let r = 0; r < rows; r++) {
      for (let c = 0; c < cols; c++) {
        dots.push({
          x: c * cellSize + cellSize / 2,
          y: r * cellSize + cellSize / 2,
          baseOpacity: Math.random() * 0.04 + 0.01,
          phase: Math.random() * Math.PI * 2,
        });
      }
    }

    let frame: number;
    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      const time = Date.now() / 3000;

      for (const dot of dots) {
        const opacity = dot.baseOpacity + Math.sin(time + dot.phase) * 0.02;
        ctx.fillStyle = `rgba(30, 58, 138, ${Math.max(0, Math.min(1, opacity))})`;
        ctx.beginPath();
        ctx.arc(dot.x, dot.y, 1.5, 0, Math.PI * 2);
        ctx.fill();
      }

      frame = requestAnimationFrame(animate);
    };

    animate();

    return () => {
      cancelAnimationFrame(frame);
      window.removeEventListener('resize', resize);
    };
  }, []);

  return <canvas ref={canvasRef} className="absolute inset-0 size-full" aria-hidden="true" />;
}
