import { Controller, Get, Post, Body, Param, UseGuards, Request, Patch, Delete } from '@nestjs/common';
import { LearningService } from './learning.service';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('learning')
@UseGuards(SupabaseAuthGuard)
export class LearningController {
  constructor(private readonly learningService: LearningService) {}

  @Get('subjects')
  async findAllSubjects(@Request() req: any) {
    return this.learningService.findAllSubjects(req.user.sub);
  }

  @Get('subjects/:id')
  async findSubjectDetails(@Request() req: any, @Param('id') id: string) {
    return this.learningService.findSubjectDetails(req.user.sub, id);
  }

  @Post('subjects')
  async createSubject(@Request() req: any, @Body() body: { title: string; category?: string }) {
    return this.learningService.createSubject(req.user.sub, body);
  }

  @Post('chapters')
  async addChapter(@Request() req: any, @Body() body: { subjectId: string; title: string }) {
    return this.learningService.addChapter(req.user.sub, body.subjectId, body.title);
  }

  @Post('topics')
  async addTopic(@Request() req: any, @Body() body: { chapterId: string; title: string }) {
    return this.learningService.addTopic(req.user.sub, body.chapterId, body.title);
  }

  @Patch('topics/:id')
  async updateTopic(@Request() req: any, @Param('id') id: string, @Body() body: { status: string }) {
    return this.learningService.updateTopic(req.user.sub, id, body);
  }

  @Patch('chapters/:id')
  async updateChapter(@Request() req: any, @Param('id') id: string, @Body() body: any) {
    return this.learningService.updateChapter(req.user.sub, id, body);
  }

  @Delete('subjects/:id')
  async deleteSubject(@Request() req: any, @Param('id') id: string) {
    return this.learningService.deleteSubject(req.user.sub, id);
  }
}
