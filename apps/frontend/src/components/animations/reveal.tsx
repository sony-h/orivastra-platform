'use client';

import { motion, useInView, type Variant } from 'framer-motion';
import { useRef } from 'react';

interface RevealProps {
  direction?: 'up' | 'down' | 'left' | 'right';
  delay?: number;
  duration?: number;
  once?: boolean;
  children: React.ReactNode;
  className?: string;
}

const directionVariants: Record<string, Variant> = {
  up: { y: 24, opacity: 0 },
  down: { y: -24, opacity: 0 },
  left: { x: 24, opacity: 0 },
  right: { x: -24, opacity: 0 },
};

export function Reveal({
  direction = 'up',
  delay = 0,
  duration = 0.4,
  once = true,
  children,
  className,
}: RevealProps) {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once, margin: '-100px' });

  return (
    <motion.div
      ref={ref}
      initial="hidden"
      animate={isInView ? 'visible' : 'hidden'}
      variants={{
        hidden: { opacity: 0, ...directionVariants[direction] },
        visible: { opacity: 1, x: 0, y: 0 },
      }}
      transition={{ duration, delay, ease: 'easeOut' }}
      className={className}
    >
      {children}
    </motion.div>
  );
}
