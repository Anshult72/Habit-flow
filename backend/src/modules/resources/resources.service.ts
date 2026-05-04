import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CacheService } from '../cache/cache.service';

@Injectable()
export class ResourcesService {
  constructor(
    private prisma: PrismaService,
    private cache: CacheService,
  ) {}

  async findAll() {
    const cacheKey = 'resources:all';
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const resources = await this.prisma.resource.findMany({
      orderBy: { createdAt: 'desc' },
    });

    await this.cache.set(cacheKey, resources, 3600); // 1 hour cache
    return resources;
  }

  async findOne(slug: string) {
    const cacheKey = `resource:${slug}`;
    const cached = await this.cache.get(cacheKey);
    if (cached) return cached;

    const resource = await this.prisma.resource.findUnique({
      where: { slug },
    });

    if (resource) {
      await this.cache.set(cacheKey, resource, 3600);
    }
    return resource;
  }
}
