'use client';

import { motion } from 'framer-motion';
import { Check, Sparkles, Crown, Rocket, BarChart3, Brain, Users, Headphones, Flame, Calendar, Smartphone, Target } from 'lucide-react';

const plans = [
  {
    name: 'Free',
    price: '$0',
    period: 'forever',
    tagline: 'For casual habit builders',
    highlighted: false,
    cta: 'Start Free',
    features: [
      { icon: Target, text: 'Basic habit tracking' },
      { icon: Flame, text: 'Daily streaks' },
      { icon: Calendar, text: 'Weekly overview' },
      { icon: Smartphone, text: 'Mobile access' },
    ],
  },
  {
    name: 'Pro',
    price: '$9',
    period: '/month',
    tagline: 'For serious productivity users',
    highlighted: true,
    badge: 'Most Popular',
    cta: 'Upgrade to Pro',
    features: [
      { icon: BarChart3, text: 'Advanced analytics' },
      { icon: Brain, text: 'AI productivity insights' },
      { icon: Sparkles, text: 'Heatmaps & charts' },
      { icon: Rocket, text: 'AI habit suggestions' },
      { icon: Target, text: 'Unlimited habits' },
      { icon: Calendar, text: 'Custom reminders' },
    ],
  },
  {
    name: 'Elite',
    price: '$24',
    period: '/month',
    tagline: 'For high-performance individuals',
    highlighted: false,
    cta: 'Unlock Elite',
    features: [
      { icon: Crown, text: 'Deep analytics dashboard' },
      { icon: Brain, text: 'Advanced AI recommendations' },
      { icon: Smartphone, text: 'Cross-device sync' },
      { icon: Users, text: 'Team accountability' },
      { icon: Headphones, text: 'Priority support' },
      { icon: Sparkles, text: 'Exclusive productivity systems' },
    ],
  },
];

const stats = [
  { value: '12K+', label: 'Active users' },
  { value: '1.2M', label: 'Habits tracked' },
  { value: '98%', label: 'Consistency rate' },
  { value: '4.9★', label: 'Average rating' },
];

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.15,
      delayChildren: 0.2,
    },
  },
};

const cardVariants = {
  hidden: { opacity: 0, y: 60 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      type: 'spring',
      damping: 20,
      stiffness: 100,
      mass: 0.8,
    },
  },
};

export default function PremiumPage() {
  return (
    <div className="relative min-h-screen">
      <main className="relative z-10 pt-32 pb-20">
        <section id="pricing" className="relative pb-20 overflow-hidden">
          <div className="relative z-10 max-w-7xl mx-auto px-6 md:px-12 lg:px-16">
            <motion.div
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-100px' }}
              transition={{ duration: 1, ease: [0.16, 1, 0.3, 1] }}
              className="text-center mb-20"
            >
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
                className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-[#FF6B2C]/15 bg-[#050505]/40 text-[#FF8C42]/70 mb-8 backdrop-blur-xl shadow-[0_0_15px_rgba(255,107,44,0.1)]"
              >
                <Crown size={14} className="text-[#FF6B2C]/60" />
                <span className="text-xs font-medium tracking-[0.15em] uppercase">Premium Plans</span>
              </motion.div>

              <h2 className="text-4xl md:text-6xl lg:text-7xl font-display font-bold text-white tracking-tight mb-8">
                Unlock Your Full{' '}
                <span className="text-transparent bg-clip-text" style={{ backgroundImage: 'linear-gradient(90deg, #FF6B2C, #FF8C42, #FFB347)' }}>
                  Potential
                </span>
              </h2>
              <p className="text-lg md:text-xl text-text-muted max-w-3xl mx-auto font-light leading-relaxed">
                Elevate your consistency, unlock advanced analytics, and receive AI-powered 
                insights designed to accelerate your personal growth.
              </p>
            </motion.div>

            <motion.div
              variants={containerVariants}
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, margin: '-80px' }}
              className="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-10 items-start"
            >
              {plans.map((plan, i) => (
                <motion.div
                  key={plan.name}
                  variants={cardVariants}
                  whileHover={{
                    y: -10,
                    transition: { type: 'spring', damping: 20, stiffness: 300 },
                  }}
                  className={`relative rounded-3xl p-[1px] group ${
                    plan.highlighted
                      ? 'md:-mt-6 md:mb-6'
                      : ''
                  }`}
                >
                  <div
                    className={`absolute inset-0 rounded-3xl transition-opacity duration-500 ${
                      plan.highlighted
                        ? 'bg-gradient-to-b from-[#FF6B2C]/40 via-[#FF6B2C]/10 to-transparent opacity-100'
                        : 'bg-gradient-to-b from-white/10 via-white/5 to-transparent opacity-40 group-hover:opacity-70'
                    }`}
                  />

                  <div
                    className={`relative rounded-3xl p-8 lg:p-12 flex flex-col h-full backdrop-blur-xl ${
                      plan.highlighted
                        ? 'bg-[#0A0A0A]/90 shadow-[0_0_60px_rgba(255,107,44,0.12)] border border-[#FF6B2C]/20'
                        : 'bg-[#080808]/80 shadow-[0_8px_40px_rgba(0,0,0,0.4)] border border-white/[0.05]'
                    }`}
                  >
                    {plan.badge && (
                      <div className="absolute -top-4 left-1/2 -translate-x-1/2 px-4 py-1.5 rounded-full bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white text-xs font-semibold tracking-wide uppercase shadow-[0_4px_20px_rgba(255,107,44,0.4)]">
                        {plan.badge}
                      </div>
                    )}

                    <div className="mb-8">
                      <h3 className={`text-2xl font-bold font-display mb-1.5 ${
                        plan.highlighted ? 'text-[#FF8C42]' : 'text-white'
                      }`}>
                        {plan.name}
                      </h3>
                      <p className="text-text-muted text-sm">{plan.tagline}</p>
                    </div>

                    <div className="mb-8 flex items-baseline gap-1">
                      <span className={`text-6xl lg:text-7xl font-display font-bold tracking-tight ${
                        plan.highlighted ? 'text-white' : 'text-white/90'
                      }`}>
                        {plan.price}
                      </span>
                      <span className="text-text-muted text-base font-light">{plan.period}</span>
                    </div>

                    <div className={`h-px mb-8 ${
                      plan.highlighted
                        ? 'bg-gradient-to-r from-transparent via-[#FF6B2C]/30 to-transparent'
                        : 'bg-white/5'
                    }`} />

                    <ul className="space-y-5 mb-12 flex-1">
                      {plan.features.map((feature, fi) => (
                        <li key={fi} className="flex items-center gap-4 group/item">
                          <div className={`w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 transition-colors ${
                            plan.highlighted
                              ? 'bg-[#FF6B2C]/10 text-[#FF6B2C] group-hover/item:bg-[#FF6B2C]/20'
                              : 'bg-white/5 text-white/50 group-hover/item:text-[#FF8C42] group-hover/item:bg-[#FF8C42]/10'
                          }`}>
                            <feature.icon size={18} />
                          </div>
                          <span className={`text-sm font-medium ${
                            plan.highlighted ? 'text-white/90' : 'text-white/70'
                          }`}>
                            {feature.text}
                          </span>
                        </li>
                      ))}
                    </ul>

                    <button
                      className={`shine-sweep w-full py-4 rounded-xl font-semibold text-lg transition-all duration-300 active:scale-95 ${
                        plan.highlighted
                          ? 'bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white shadow-[0_0_20px_rgba(255,107,44,0.3)] hover:shadow-[0_0_40px_rgba(255,107,44,0.6)] hover:-translate-y-1'
                          : 'bg-white/5 border border-white/10 text-white/90 hover:bg-[#FF6B2C]/10 hover:border-[#FF6B2C]/40 hover:text-white hover:shadow-[0_0_20px_rgba(255,107,44,0.15)] hover:scale-[1.02]'
                      }`}
                    >
                      {plan.cta}
                    </button>
                  </div>
                </motion.div>
              ))}
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-60px' }}
              transition={{ duration: 1, delay: 0.3, ease: [0.16, 1, 0.3, 1] }}
              className="mt-24 md:mt-32 text-center"
            >
              <p className="text-sm text-text-muted/60 tracking-[0.12em] uppercase font-medium mb-10">
                Trusted by ambitious creators worldwide
              </p>

              <div className="grid grid-cols-2 md:grid-cols-4 gap-6 md:gap-10 max-w-4xl mx-auto">
                {stats.map((stat, i) => (
                  <motion.div
                    key={i}
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.6, delay: 0.1 * i, ease: [0.16, 1, 0.3, 1] }}
                    className="relative group"
                  >
                    <div className="absolute inset-0 rounded-2xl bg-[#FF6B2C]/5 opacity-0 group-hover:opacity-100 blur-xl transition-opacity pointer-events-none" />
                    <div className="relative bg-[#080808]/60 backdrop-blur-lg border border-white/5 group-hover:border-[#FF6B2C]/20 rounded-2xl px-4 py-6 transition-colors">
                      <p className="text-3xl md:text-4xl font-display font-bold text-white mb-1 tracking-tight">
                        {stat.value}
                      </p>
                      <p className="text-xs text-text-muted font-medium tracking-wide uppercase">
                        {stat.label}
                      </p>
                    </div>
                  </motion.div>
                ))}
              </div>
            </motion.div>
          </div>
        </section>
      </main>
    </div>
  );
}
