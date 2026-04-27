import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { AnimatePresence, motion } from 'framer-motion';
import { Toaster } from 'react-hot-toast';
import SceneWrapper from './components/SceneWrapper';
import Navbar from './components/Navbar';
import Landing from './pages/Landing';
import DashboardLayout from './layouts/DashboardLayout';
import Dashboard from './pages/Dashboard';
import Habits from './pages/Habits';
import Analytics from './pages/Analytics';
import CalendarPage from './pages/CalendarPage';
import Settings from './pages/Settings';
import HelpCenter from './pages/HelpCenter';
import Achievements from './pages/Achievements';
import Reports from './pages/Reports';
import PWAInstallButton from './components/PWAInstallButton';
import PremiumPage from './pages/PremiumPage';
import FeaturesPage from './pages/FeaturesPage';
import Onboarding from './pages/Onboarding';
import AchievementNotifier from './components/AchievementNotifier';
import LeaderboardPage from './pages/LeaderboardPage';

function OnboardingCheck({ children }) {
  const hasCompleted = localStorage.getItem('hasCompletedOnboarding') === 'true';
  if (!hasCompleted) {
    return <Navigate to="/onboarding" replace />;
  }
  return children;
}

function AnimatedRoutes() {
  const location = useLocation();

  return (
    <AnimatePresence mode="wait">
      <Routes location={location} key={location.pathname}>
        <Route path="/" element={<Landing />} />
        <Route path="/features" element={<FeaturesPage />} />
        <Route path="/onboarding" element={<Onboarding />} />
        <Route path="/premium" element={<PremiumPage />} />
        <Route path="/help" element={<HelpCenter />} />
        <Route path="/app" element={
          <OnboardingCheck>
            <DashboardLayout />
          </OnboardingCheck>
        }>
          <Route index element={<Dashboard />} />
          <Route path="habits" element={<Habits />} />
          <Route path="analytics" element={<Analytics />} />
          <Route path="calendar" element={<CalendarPage />} />
          <Route path="achievements" element={<Achievements />} />
          <Route path="reports" element={<Reports />} />
          <Route path="leaderboard" element={<LeaderboardPage />} />
          <Route path="settings" element={<Settings />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </AnimatePresence>
  );
}

function App() {
  return (
    <Router>
      <Toaster 
        position="top-center"
        toastOptions={{
          style: {
            background: 'rgba(20, 20, 25, 0.9)',
            color: '#fff',
            backdropFilter: 'blur(10px)',
            border: '1px solid rgba(255, 107, 44, 0.2)',
          },
          success: {
            iconTheme: {
              primary: '#FF6B2C',
              secondary: '#fff',
            },
          },
        }}
      />
      <SceneWrapper>
        <motion.div
          initial={{ y: -20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1], delay: 0.2 }}
        >
          <Navbar />
        </motion.div>
        <AnimatedRoutes />
        <PWAInstallButton />
        <AchievementNotifier />
      </SceneWrapper>
    </Router>
  );
}

export default App;
