import { useState, useEffect, useCallback } from 'react';
import { motion, useSpring, useMotionValue } from 'framer-motion';

export default function SceneWrapper({ children }) {
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  const springConfig = { damping: 25, stiffness: 150 };
  const smoothX = useSpring(mouseX, springConfig);
  const smoothY = useSpring(mouseY, springConfig);

  const [isIdle, setIsIdle] = useState(false);
  let idleTimer;

  const handleMouseMove = useCallback((e) => {
    mouseX.set(e.clientX);
    mouseY.set(e.clientY);
    setIsIdle(false);
    clearTimeout(idleTimer);
    idleTimer = setTimeout(() => setIsIdle(true), 2000);
  }, [mouseX, mouseY]);

  useEffect(() => {
    window.addEventListener('mousemove', handleMouseMove);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      clearTimeout(idleTimer);
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
        className="fixed top-0 left-0 w-[600px] h-[600px] z-[3] pointer-events-none mix-blend-screen"
        style={{
          x: smoothX,
          y: smoothY,
          translateX: '-50%',
          translateY: '-50%',
        }}
      >
        <motion.div
          animate={{
            scale: isIdle ? 0.8 : 1,
            opacity: isIdle ? 0.08 : 0.18,
          }}
          className="w-full h-full bg-[radial-gradient(circle_at_center,rgba(255,140,66,1)_0%,rgba(255,107,44,0.6)_40%,transparent_70%)] blur-[100px]"
        />
      </motion.div>

      {/* Layer 5: Ambient Radial Gradients */}
      <div className="fixed inset-0 z-[4] pointer-events-none mix-blend-screen">
        <div className="absolute top-[-10%] left-[-10%] w-[60%] h-[60%] bg-[#FF6B2C]/10 rounded-full blur-[150px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] bg-[#E85D04]/10 rounded-full blur-[150px]" />
      </div>

      {/* Layer 6: Floating Particles (Subtle) */}
      <div className="fixed inset-0 z-[5] pointer-events-none">
        {[...Array(20)].map((_, i) => (
          <motion.div
            key={i}
            initial={{ 
              x: Math.random() * window.innerWidth, 
              y: Math.random() * window.innerHeight 
            }}
            animate={{
              y: [null, Math.random() * -100 - 50],
              opacity: [0, 0.3, 0],
            }}
            transition={{
              duration: Math.random() * 10 + 10,
              repeat: Infinity,
              ease: "linear",
            }}
            className="absolute w-1 h-1 bg-white rounded-full"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
            }}
          />
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
