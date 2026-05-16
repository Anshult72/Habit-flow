import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class LearningService {
  constructor(private prisma: PrismaService) {}

  async findAllSubjects(supabaseId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    return this.prisma.subject.findMany({
      where: { userId: user.id },
      include: {
        _count: {
          select: { chapters: true },
        },
      },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async findSubjectDetails(supabaseId: string, subjectId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    const subject = await this.prisma.subject.findUnique({
      where: { id: subjectId },
      include: {
        chapters: {
          include: {
            topics: {
              orderBy: { createdAt: 'asc' },
            },
          },
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!subject || subject.userId !== user.id) throw new NotFoundException('Subject not found');
    return subject;
  }

  async createSubject(supabaseId: string, data: { title: string; category?: string }) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new NotFoundException('User not found');

    return this.prisma.subject.create({
      data: {
        ...data,
        userId: user.id,
      },
    });
  }

  async addChapter(supabaseId: string, subjectId: string, title: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    const subject = await this.prisma.subject.findUnique({ where: { id: subjectId } });

    if (!subject || subject.userId !== user?.id) throw new NotFoundException('Subject not found');

    return this.prisma.chapter.create({
      data: {
        title,
        subjectId,
      },
    });
  }

  async addTopic(supabaseId: string, chapterId: string, title: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    const chapter = await this.prisma.chapter.findUnique({
      where: { id: chapterId },
      include: { subject: true },
    });

    if (!chapter || chapter.subject.userId !== user?.id) throw new NotFoundException('Chapter not found');

    return this.prisma.topic.create({
      data: {
        title,
        chapterId,
      },
    });
  }

  async updateTopic(supabaseId: string, topicId: string, data: { status: string }) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    const topic = await this.prisma.topic.findUnique({
      where: { id: topicId },
      include: { chapter: { include: { subject: true } } },
    });

    if (!topic || topic.chapter.subject.userId !== user?.id) throw new NotFoundException('Topic not found');

    const updatedTopic = await this.prisma.topic.update({
      where: { id: topicId },
      data,
    });

    // Auto-update chapter and subject progress
    await this.recalculateProgress(topic.chapter.id, topic.chapter.subject.id);

    return updatedTopic;
  }

  async updateChapter(supabaseId: string, chapterId: string, data: { status?: string; notes?: string }) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    const chapter = await this.prisma.chapter.findUnique({
      where: { id: chapterId },
      include: { subject: true },
    });

    if (!chapter || chapter.subject.userId !== user?.id) throw new NotFoundException('Chapter not found');

    return this.prisma.chapter.update({
      where: { id: chapterId },
      data,
    });
  }

  async deleteSubject(supabaseId: string, subjectId: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    const subject = await this.prisma.subject.findUnique({ where: { id: subjectId } });

    if (!subject || subject.userId !== user?.id) throw new NotFoundException('Subject not found');

    return this.prisma.subject.delete({ where: { id: subjectId } });
  }

  private async recalculateProgress(chapterId: string, subjectId: string) {
    // Recalculate Chapter Progress based on Topics
    const topics = await this.prisma.topic.findMany({ where: { chapterId } });
    const completedTopics = topics.filter((t) => t.status === 'Completed').length;
    const chapterProgress = topics.length > 0 ? Math.round((completedTopics / topics.length) * 100) : 0;
    
    let chapterStatus = 'Not Started';
    if (chapterProgress === 100) chapterStatus = 'Completed';
    else if (chapterProgress > 0) chapterStatus = 'In Progress';

    await this.prisma.chapter.update({
      where: { id: chapterId },
      data: { progress: chapterProgress, status: chapterStatus },
    });

    // Recalculate Subject Progress based on Chapters
    const chapters = await this.prisma.chapter.findMany({ where: { subjectId } });
    const subjectProgress = chapters.length > 0 ? Math.round(chapters.reduce((acc, c) => acc + c.progress, 0) / chapters.length) : 0;

    await this.prisma.subject.update({
      where: { id: subjectId },
      data: { progress: subjectProgress },
    });
  }
}
