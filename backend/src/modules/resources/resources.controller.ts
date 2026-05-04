import { Controller, Get, Param } from '@nestjs/common';
import { ResourcesService } from './resources.service';

@Controller('resources')
export class ResourcesController {
  constructor(private readonly resourcesService: ResourcesService) {}

  @Get()
  async findAll() {
    return this.resourcesService.findAll();
  }

  @Get(':slug')
  async findOne(@Param('slug') slug: string) {
    return this.resourcesService.findOne(slug);
  }
}
