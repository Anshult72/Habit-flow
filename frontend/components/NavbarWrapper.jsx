'use client';

import { usePathname } from 'next/navigation';
import Navbar from './Navbar';

export default function NavbarWrapper() {
  const pathname = usePathname();
  
  // Hide navbar on authenticated app routes and onboarding
  const isAppRoute = pathname?.startsWith('/app');
  const isOnboarding = pathname === '/onboarding';
  
  if (isAppRoute || isOnboarding) {
    return null;
  }

  return <Navbar />;
}
