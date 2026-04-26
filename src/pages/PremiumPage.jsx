import { motion } from 'framer-motion';
import PricingSection from '../components/PricingSection';

export default function PremiumPage() {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
      className="min-h-screen font-sans relative"
    >
      <main className="relative z-10 pt-10 pb-20">
        <PricingSection />
      </main>
    </motion.div>
  );
}
