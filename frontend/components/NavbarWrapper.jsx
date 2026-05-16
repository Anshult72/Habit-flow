'use client';

import { usePathname } from 'next/navigation';
import Navbar from './Navbar';

export default function NavbarWrapper() {
  const pathname = usePathname();
  
  // Hide navbar on authenticated app routes, onboarding, and auth redirect flows
  const isAppRoute = pathname?.startsWith('/app');
  const isOnboarding = pathname === '/onboarding';
  const isAuthFlow = pathname?.startsWith('/auth');
  
  if (isAppRoute || isOnboarding || isAuthFlow) {
    return null;
  }

  return <Navbar />;
}
