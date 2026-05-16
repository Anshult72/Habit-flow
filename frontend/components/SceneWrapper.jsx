'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import { motion, useSpring, useMotionValue } from 'framer-motion';

export default function SceneWrapper({ children }) {
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  const springConfig = { damping: 25, stiffness: 150 };
  const smoothX = useSpring(mouseX, springConfig);
  const smoothY = useSpring(mouseY, springConfig);

  const [isIdle, setIsIdle] = useState(false);
  const idleTimerRef = useRef(null);

  const handleMouseMove = useCallback((e) => {
    mouseX.set(e.clientX);
    mouseY.set(e.clientY);
    setIsIdle(false);
    clearTimeout(idleTimerRef.current);
    idleTimerRef.current = setTimeout(() => setIsIdle(true), 2000);
  }, [mouseX, mouseY]);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    window.addEventListener('mousemove', handleMouseMove);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      clearTimeout(idleTimerRef.current);
    };
  }, [handleMouseMove]);

  return (
    <div className="relative min-h-screen bg-[#050505] overflow-hidden">
      {/* Layer 1: Base Background */}
      <div className="fixed inset-0 z-0 bg-[#050505]" />

      {/* Layer 2: Grid Pattern */}
      <div className="fixed inset-0 z-[1] grid-pattern pointer-events-none opacity-[0.4]" />

      {/* Layer 3: Noise Texture */}
      <div className="fixed inset-0 z-[2] noise-overlay pointer-events-none" />

      {/* Layer 4: Global Cursor Glow */}
      <motion.div
        className="fixed top-0 left-0 w-[800px] h-[800px] z-[9999] pointer-events-none mix-blend-screen overflow-visible"
        style={{
          x: smoothX,
          y: smoothY,
          translateX: '-50%',
          translateY: '-50%',
        }}
      >
        <motion.div
          animate={{
            scale: isIdle ? 0.7 : 1,
            opacity: isIdle ? 0.05 : 0.22,
          }}
          transition={{ duration: 1.5, ease: "easeOut" }}
          className="w-full h-full bg-[radial-gradient(circle_at_center,rgba(255,107,44,0.8)_0%,rgba(255,107,44,0.3)_45%,transparent_75%)] blur-[120px]"
        />
      </motion.div>

      {/* Layer 5: Ambient Radial Gradients & Watermark */}
      <div className="fixed inset-0 z-[4] pointer-events-none mix-blend-screen overflow-hidden">
        <div className="absolute top-[-10%] left-[-10%] w-[60%] h-[60%] bg-[#FF6B2C]/10 rounded-full blur-[150px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] bg-[#E85D04]/10 rounded-full blur-[150px]" />
        
        {/* Eagle Watermark */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[1200px] h-[1200px] opacity-[0.015] grayscale pointer-events-none">
          <img src="/assets/eagle-logo-transparent.png" alt="" className="w-full h-full object-contain" />
        </div>
      </div>

      {/* Layer 6: Floating Particles (Subtle) */}
      <div className="fixed inset-0 z-[5] pointer-events-none">
        {[...Array(20)].map((_, i) => (
          <Particle key={i} />
        ))}
      </div>

      {/* Layer 7: Vignette */}
      <div className="fixed inset-0 z-[6] vignette-overlay pointer-events-none" />

      {/* Content */}
      <div className="relative z-10">
        {children}
      </div>
    </div>
  );
}

function Particle() {
  const [mounted, setMounted] = useState(false);
  const [props, setProps] = useState({ x: 0, y: 0, left: '0%', top: '0%', yAnim: 0, duration: 10 });

  useEffect(() => {
    const t = setTimeout(() => {
      setProps({
        x: Math.random() * window.innerWidth,
        y: Math.random() * window.innerHeight,
        left: `${Math.random() * 100}%`,
        top: `${Math.random() * 100}%`,
        yAnim: Math.random() * -100 - 50,
        duration: Math.random() * 10 + 10
      });
      setMounted(true);
    }, 0);
    return () => clearTimeout(t);
  }, []);

  if (!mounted) return null;

  return (
    <motion.div
      initial={{ 
        x: props.x, 
        y: props.y 
      }}
      animate={{
        y: [null, props.yAnim],
        opacity: [0, 0.3, 0],
      }}
      transition={{
        duration: props.duration,
        repeat: Infinity,
        ease: "linear",
      }}
      className="absolute w-1 h-1 bg-white rounded-full"
      style={{
        left: props.left,
        top: props.top,
      }}
    />
  );
}
