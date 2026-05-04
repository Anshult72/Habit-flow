import { Controller } from '@nestjs/common';
import { LearningService } from './learning.service';

@Controller('learning')
export class LearningController {
  constructor(private readonly learningService: LearningService) {}
}
