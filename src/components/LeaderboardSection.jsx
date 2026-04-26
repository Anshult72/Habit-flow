import { motion } from 'framer-motion';
import { Crown, Flame, Zap, Trophy, TrendingUp, Award, Star, Target } from 'lucide-react';

const topPerformers = [
  {
    rank: 2,
    name: 'Elena Vasquez',
    avatar: 'EV',
    avatarColor: 'from-[#FF8C42] to-[#E85D04]',
    score: 9420,
    streak: 84,
    level: 42,
    xp: '84.2K',
    completion: 94,
    title: 'Productivity Elite',
    badges: [Trophy, Star, Flame],
  },
  {
    rank: 1,
    name: 'Arjun Mehta',
    avatar: 'AM',
    avatarColor: 'from-[#FF6B2C] to-[#FFB347]',
    score: 11250,
    streak: 127,
    level: 58,
    xp: '116K',
    completion: 98,
    title: 'Consistency Master',
    badges: [Crown, Trophy, Flame, Star],
  },
  {
    rank: 3,
    name: 'Sofia Chen',
    avatar: 'SC',
    avatarColor: 'from-[#E85D04] to-[#FF6B2C]',
    score: 8890,
    streak: 63,
    level: 37,
    xp: '72.5K',
    completion: 91,
    title: 'Focus Champion',
    badges: [Target, Flame],
  },
];

const leaderboardList = [
  { rank: 4, name: 'Marcus Johnson', avatar: 'MJ', score: 8210, streak: 52, level: 34, xp: '66.1K', completion: 89, title: 'Habit Warrior' },
  { rank: 5, name: 'Yuki Tanaka', avatar: 'YT', score: 7840, streak: 47, level: 31, xp: '58.9K', completion: 87, title: 'Streak Hunter' },
  { rank: 6, name: 'Priya Sharma', avatar: 'PS', score: 7520, streak: 41, level: 29, xp: '54.3K', completion: 85, title: 'Growth Seeker', isCurrentUser: true },
  { rank: 7, name: 'Liam O\'Brien', avatar: 'LO', score: 7100, streak: 38, level: 27, xp: '49.8K', completion: 83, title: 'Rising Star' },
  { rank: 8, name: 'Amara Obi', avatar: 'AO', score: 6780, streak: 34, level: 25, xp: '45.2K', completion: 80, title: 'Momentum Builder' },
  { rank: 9, name: 'Noah Kim', avatar: 'NK', score: 6400, streak: 29, level: 23, xp: '41.6K', completion: 78, title: 'Daily Achiever' },
  { rank: 10, name: 'Zara Ahmed', avatar: 'ZA', score: 6050, streak: 25, level: 21, xp: '38.1K', completion: 76, title: 'Path Finder' },
];

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.12, delayChildren: 0.15 },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 40 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { type: 'spring', damping: 20, stiffness: 100 },
  },
};

function PodiumCard({ user }) {
  const isChampion = user.rank === 1;
  const sizeClasses = isChampion
    ? 'w-full max-w-[300px] md:max-w-[340px] lg:max-w-[360px]'
    : 'w-full max-w-[260px] md:max-w-[300px] lg:max-w-[320px]';

  return (
    <motion.div
      variants={itemVariants}
      whileHover={{ y: -12, transition: { type: 'spring', damping: 20, stiffness: 300 } }}
      className={`relative ${sizeClasses} ${isChampion ? 'md:-mt-12 order-2 md:order-2' : user.rank === 2 ? 'order-1 md:order-1' : 'order-3 md:order-3'}`}
    >
      {/* Ambient glow for champion */}
      {isChampion && (
        <div className="absolute -inset-6 bg-[#FF6B2C]/15 rounded-[2.5rem] blur-2xl pointer-events-none" />
      )}

      {/* Card border gradient */}
      <div className={`absolute inset-0 rounded-3xl ${
        isChampion
          ? 'bg-gradient-to-b from-[#FF6B2C]/50 via-[#FF6B2C]/15 to-transparent'
          : 'bg-gradient-to-b from-white/10 via-white/5 to-transparent'
      }`} />

      <div className={`relative rounded-3xl p-7 md:p-9 lg:p-10 backdrop-blur-xl flex flex-col items-center text-center border border-white/[0.05] ${
        isChampion
          ? 'bg-[#0A0A0A]/95 shadow-[0_0_50px_rgba(255,107,44,0.15)]'
          : 'bg-[#080808]/80 shadow-[0_8px_40px_rgba(0,0,0,0.4)]'
      }`}>
        {/* Rank Badge */}
        <div className={`absolute -top-4 left-1/2 -translate-x-1/2 w-9 h-9 rounded-full flex items-center justify-center text-xs font-bold ${
          isChampion
            ? 'bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] text-white shadow-[0_0_15px_rgba(255,107,44,0.5)]'
            : user.rank === 2
              ? 'bg-[#C0C0C0]/20 border border-[#C0C0C0]/40 text-[#C0C0C0]'
              : 'bg-[#CD7F32]/20 border border-[#CD7F32]/40 text-[#CD7F32]'
        }`}>
          {isChampion ? <Crown size={14} /> : `#${user.rank}`}
        </div>

        {/* Avatar */}
        <div className={`w-20 h-20 md:w-24 md:h-24 rounded-2xl bg-gradient-to-br ${user.avatarColor} flex items-center justify-center mb-5 mt-2 ${
          isChampion ? 'shadow-[0_0_30px_rgba(255,107,44,0.35)]' : 'shadow-lg'
        }`}>
          <span className="text-white font-bold text-xl md:text-2xl">{user.avatar}</span>
        </div>

        {/* Name & Title */}
        <h3 className={`font-bold font-display mb-1 ${isChampion ? 'text-xl text-white' : 'text-lg text-white/90'}`}>
          {user.name}
        </h3>
        <p className={`text-xs font-medium tracking-wide mb-4 ${
          isChampion ? 'text-[#FF8C42]' : 'text-textMuted'
        }`}>
          {user.title}
        </p>

        {/* Score */}
        <div className="mb-5">
          <p className={`font-display font-bold tracking-tight ${isChampion ? 'text-4xl text-white' : 'text-3xl text-white/90'}`}>
            {user.score.toLocaleString()}
          </p>
          <p className="text-[11px] text-textMuted uppercase tracking-widest mt-0.5">Productivity Score</p>
        </div>

        {/* Stats Row */}
        <div className="flex items-center justify-center gap-4 mb-5 w-full">
          <div className="text-center">
            <div className="flex items-center justify-center gap-1 text-[#FF6B2C] mb-0.5">
              <Flame size={15} />
              <span className="text-base font-bold">{user.streak}</span>
            </div>
            <p className="text-[10px] text-textMuted uppercase tracking-wider">Streak</p>
          </div>
          <div className="w-px h-8 bg-white/5" />
          <div className="text-center">
            <div className="flex items-center justify-center gap-1 text-[#FF8C42] mb-0.5">
              <Zap size={15} />
              <span className="text-base font-bold">Lv.{user.level}</span>
            </div>
            <p className="text-[10px] text-textMuted uppercase tracking-wider">Level</p>
          </div>
          <div className="w-px h-8 bg-white/5" />
          <div className="text-center">
            <p className="text-base font-bold text-white/80 mb-0.5">{user.completion}%</p>
            <p className="text-[10px] text-textMuted uppercase tracking-wider">Rate</p>
          </div>
        </div>

        {/* Completion Bar */}
        <div className="w-full h-1.5 rounded-full bg-white/5 overflow-hidden mb-4">
          <motion.div
            initial={{ width: 0 }}
            whileInView={{ width: `${user.completion}%` }}
            viewport={{ once: true }}
            transition={{ duration: 1.2, delay: 0.5, ease: [0.16, 1, 0.3, 1] }}
            className={`h-full rounded-full ${
              isChampion
                ? 'bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] shadow-[0_0_8px_rgba(255,107,44,0.5)]'
                : 'bg-gradient-to-r from-[#FF6B2C]/70 to-[#FF8C42]/70'
            }`}
          />
        </div>

        {/* Badges */}
        <div className="flex items-center gap-1.5">
          {user.badges.map((Badge, bi) => (
            <div key={bi} className={`w-8 h-8 rounded-lg flex items-center justify-center ${
              isChampion
                ? 'bg-[#FF6B2C]/15 text-[#FF8C42]'
                : 'bg-white/5 text-white/40'
            }`}>
              <Badge size={15} />
            </div>
          ))}
        </div>
      </div>
    </motion.div>
  );
}

function LeaderboardRow({ user, index }) {
  return (
    <motion.div
      variants={itemVariants}
      whileHover={{ x: 6, transition: { type: 'spring', damping: 25, stiffness: 300 } }}
      className={`relative group rounded-2xl p-[1px] ${
        user.isCurrentUser ? '' : ''
      }`}
    >
      {/* Current user ambient glow */}
      {user.isCurrentUser && (
        <div className="absolute -inset-1 bg-[#FF6B2C]/10 rounded-2xl blur-lg pointer-events-none" />
      )}

      <div className={`relative flex items-center gap-4 md:gap-6 px-6 md:px-8 py-5 rounded-2xl backdrop-blur-lg transition-all duration-300 ${
        user.isCurrentUser
          ? 'bg-[#0A0A0A]/95 border border-[#FF6B2C]/25 shadow-[0_0_25px_rgba(255,107,44,0.12)]'
          : 'bg-[#080808]/60 border border-white/[0.03] group-hover:border-white/10 group-hover:bg-[#0A0A0A]/80'
      }`}>
        {/* Rank */}
        <div className={`w-9 text-center flex-shrink-0 font-display font-bold text-base ${
          user.isCurrentUser ? 'text-[#FF6B2C]' : 'text-white/30'
        }`}>
          {user.rank}
        </div>

        {/* Avatar */}
        <div className={`w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0 ${
          user.isCurrentUser
            ? 'bg-gradient-to-br from-[#FF6B2C] to-[#E85D04] shadow-[0_0_12px_rgba(255,107,44,0.3)]'
            : 'bg-white/5 border border-white/10'
        }`}>
          <span className={`font-bold text-sm ${user.isCurrentUser ? 'text-white' : 'text-white/60'}`}>
            {user.avatar}
          </span>
        </div>

        {/* Name & Title */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <p className={`font-semibold text-base truncate ${user.isCurrentUser ? 'text-white' : 'text-white/80'}`}>
              {user.name}
            </p>
            {user.isCurrentUser && (
              <span className="px-2 py-0.5 rounded-full bg-[#FF6B2C]/15 text-[#FF8C42] text-[10px] font-semibold uppercase tracking-wider flex-shrink-0 shadow-[0_0_10px_rgba(255,107,44,0.1)]">
                You
              </span>
            )}
          </div>
          <p className="text-xs text-textMuted truncate">{user.title}</p>
        </div>

        {/* Stats */}
        <div className="hidden sm:flex items-center gap-5 flex-shrink-0">
          <div className="text-center min-w-[48px]">
            <div className="flex items-center justify-center gap-1 text-[#FF6B2C]/80">
              <Flame size={14} />
              <span className="text-sm font-bold">{user.streak}</span>
            </div>
            <p className="text-[9px] text-textMuted uppercase tracking-wider">Streak</p>
          </div>
          <div className="text-center min-w-[48px]">
            <p className="text-sm font-bold text-white/70">{user.xp}</p>
            <p className="text-[9px] text-textMuted uppercase tracking-wider">XP</p>
          </div>
          <div className="text-center min-w-[48px]">
            <p className="text-sm font-bold text-white/70">Lv.{user.level}</p>
            <p className="text-[9px] text-textMuted uppercase tracking-wider">Level</p>
          </div>
        </div>

        {/* Score */}
        <div className="text-right flex-shrink-0 min-w-[60px]">
          <p className={`font-display font-bold text-base ${user.isCurrentUser ? 'text-[#FF8C42]' : 'text-white/70'}`}>
            {user.score.toLocaleString()}
          </p>
          <p className="text-[9px] text-textMuted uppercase tracking-wider">Score</p>
        </div>

        {/* Completion mini-bar */}
        <div className="hidden md:block w-20 flex-shrink-0">
          <div className="w-full h-1 rounded-full bg-white/5 overflow-hidden">
            <motion.div
              initial={{ width: 0 }}
              whileInView={{ width: `${user.completion}%` }}
              viewport={{ once: true }}
              transition={{ duration: 1, delay: 0.3 + index * 0.1, ease: [0.16, 1, 0.3, 1] }}
              className={`h-full rounded-full ${
                user.isCurrentUser
                  ? 'bg-gradient-to-r from-[#FF6B2C] to-[#FFB347] shadow-[0_0_10px_rgba(255,107,44,0.3)]'
                  : 'bg-white/20'
              }`}
            />
          </div>
          <p className="text-[9px] text-textMuted text-right mt-0.5">{user.completion}%</p>
        </div>
      </div>
    </motion.div>
  );
}

export default function LeaderboardSection() {
  return (
    <section id="leaderboard" className="relative pt-16 md:pt-20 pb-20 overflow-hidden">
      <div className="relative z-10 max-w-7xl mx-auto px-6 md:px-12 lg:px-16">
        {/* Section Header */}
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
            <Trophy size={14} className="text-[#FF6B2C]/60" />
            <span className="text-xs font-medium tracking-[0.15em] uppercase">Global Rankings</span>
          </motion.div>

          <h2 className="text-4xl md:text-6xl lg:text-7xl font-display font-bold text-white tracking-tight mb-6">
            Top{' '}
            <span className="text-transparent bg-clip-text" style={{ backgroundImage: 'linear-gradient(90deg, #FF6B2C, #FF8C42, #FFB347)' }}>
              Performers
            </span>
          </h2>
          <p className="text-lg md:text-xl text-textMuted max-w-2xl mx-auto font-light leading-relaxed">
            Compete with ambitious individuals worldwide. Build streaks, earn XP, 
            and climb the ranks through consistent daily action.
          </p>
        </motion.div>

        {/* Top 3 Podium */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: '-60px' }}
          className="flex flex-col md:flex-row items-end justify-center gap-6 md:gap-8 mb-16 md:mb-24"
        >
          {topPerformers.map((user) => (
            <PodiumCard key={user.rank} user={user} />
          ))}
        </motion.div>

        {/* Full Leaderboard List */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: '-40px' }}
          className="space-y-3"
        >
          {/* List Header */}
          <div className="flex items-center justify-between px-8 mb-4">
            <div className="flex items-center gap-2">
              <TrendingUp size={16} className="text-[#FF6B2C]/60" />
              <span className="text-xs text-textMuted font-medium tracking-[0.1em] uppercase">Full Rankings</span>
            </div>
            <span className="text-xs text-textMuted/50 font-medium">Updated live</span>
          </div>

          {leaderboardList.map((user, i) => (
            <LeaderboardRow key={user.rank} user={user} index={i} />
          ))}
        </motion.div>

        {/* Motivational CTA */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, delay: 0.3, ease: [0.16, 1, 0.3, 1] }}
          className="mt-24 text-center"
        >
          <div className="inline-flex flex-col items-center gap-4 bg-[#080808]/60 backdrop-blur-xl border border-white/5 hover:border-[#FF6B2C]/20 rounded-2xl px-12 py-10 transition-colors shadow-[0_20px_50px_rgba(0,0,0,0.4)]">
            <div className="w-14 h-14 rounded-2xl bg-[#FF6B2C]/10 flex items-center justify-center shadow-[0_0_15px_rgba(255,107,44,0.1)]">
              <Award size={26} className="text-[#FF6B2C]" />
            </div>
            <p className="text-white font-display font-bold text-xl">Ready to claim your spot?</p>
            <p className="text-textMuted text-sm max-w-xs leading-relaxed">Start tracking your habits today and compete with the world's most productive individuals.</p>
            <button className="shine-sweep mt-4 px-10 py-4 rounded-xl bg-gradient-to-r from-[#FF6B2C] to-[#E85D04] text-white font-bold text-lg shadow-[0_0_20px_rgba(255,107,44,0.3)] hover:shadow-[0_0_40px_rgba(255,107,44,0.6)] hover:-translate-y-1 transition-all duration-300 active:scale-95">
              Start Competing
            </button>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
