import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Starting explicit database reset...');
  try {
    await prisma.$transaction([
      prisma.duelParticipant.deleteMany(),
      prisma.duelRequest.deleteMany(),
      prisma.duel.deleteMany(),
      prisma.squadMember.deleteMany(),
      prisma.squadRequest.deleteMany(),
      prisma.squad.deleteMany(),
      prisma.xPLog.deleteMany(),
      prisma.habitCompletion.deleteMany(),
      prisma.focusSession.deleteMany(),
      prisma.notification.deleteMany(),
      prisma.user.updateMany({
        data: {
          xp: 0,
          level: 1,
          streakShields: 2,
        },
      }),
    ]);
    console.log('Database successfully reset. XP has been zeroed.');
  } catch (error) {
    console.error('Error during reset:', error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
