import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import axios from 'axios';
import * as cheerio from 'cheerio';

@Injectable()
export class WishlistService {
  private readonly logger = new Logger(WishlistService.name);

  constructor(private prisma: PrismaService) {}

  async autoSync(url: string) {
    if (!url) {
      throw new BadRequestException('URL is required for auto-sync');
    }

    try {
      new URL(url);
    } catch {
      throw new BadRequestException('Invalid URL format provided');
    }

    try {
      this.logger.log(`Initiating Auto-Sync for URL: ${url}`);
      
      const response = await axios.get(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
        },
        timeout: 8000,
      });

      const $ = cheerio.load(response.data);

      // Extract basic metadata
      const ogTitle = $('meta[property="og:title"]').attr('content');
      const standardTitle = $('title').text();
      let title = ogTitle || standardTitle || 'Unknown Product';
      
      // Clean title
      title = title.replace(/\n/g, ' ').trim();
      if (title.length > 100) title = title.substring(0, 97) + '...';

      const image = $('meta[property="og:image"]').attr('content') || $('meta[name="twitter:image"]').attr('content') || '';
      
      // Price extraction logic
      let priceStr = $('meta[property="og:price:amount"]').attr('content') || $('meta[property="product:price:amount"]').attr('content');
      if (!priceStr) {
        priceStr = $('.a-price-whole').first().text() || $('._30jeq3').first().text() || $('.pdp-price').first().text();
      }
      
      let price = 0;
      if (priceStr) {
        const cleaned = priceStr.replace(/[^0-9.]/g, '');
        const parsed = parseFloat(cleaned);
        if (!isNaN(parsed)) price = parsed;
      }

      // Store/Brand detection
      const parsedUrl = new URL(url);
      const hostname = parsedUrl.hostname.toLowerCase();
      let store = $('meta[property="og:site_name"]').attr('content');
      
      if (!store) {
        if (hostname.includes('amazon')) store = 'Amazon';
        else if (hostname.includes('flipkart')) store = 'Flipkart';
        else if (hostname.includes('myntra')) store = 'Myntra';
        else if (hostname.includes('ajio')) store = 'Ajio';
        else if (hostname.includes('apple')) store = 'Apple';
        else if (hostname.includes('nike')) store = 'Nike';
        else store = hostname.replace('www.', '').split('.')[0];
      }

      // Intelligent Category Guessing
      let category = 'Lifestyle';
      const titleLower = title.toLowerCase();
      
      if (titleLower.match(/laptop|phone|tv|monitor|processor|keyboard|mouse|headphone|earbud|apple|samsung/)) category = 'Tech';
      else if (titleLower.match(/game|playstation|xbox|nintendo|controller/)) category = 'Gaming';
      else if (titleLower.match(/dumbell|protein|treadmill|yoga|shoe/)) category = 'Fitness';
      else if (titleLower.match(/car|bike|scooter|helmet/)) category = 'Vehicle';
      else if (titleLower.match(/book|course|tutorial/)) category = 'Education';
      else if (titleLower.match(/desk|chair|table|sofa/)) category = 'Dream Setup';

      return {
        title,
        price,
        image,
        brand: store,
        store,
        category,
        sourceUrl: url
      };
      
      
    } catch (error) {
      this.logger.error(`Auto-sync failed for URL: ${url} - ${error.message}`);
      
      // Return safe fallback instead of crashing
      return {
        title: 'Synced Target (Metadata Unavailable)',
        price: 0,
        image: '',
        brand: 'External',
        store: 'External',
        category: 'Lifestyle',
        sourceUrl: url,
        error: true
      };
    }
  }

  async findAll(supabaseId: string) {
    return this.prisma.wishlistItem.findMany({
      where: { user: { supabaseId } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(supabaseId: string, data: any) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new Error('User not found');

    return this.prisma.wishlistItem.create({
      data: {
        title: data.title,
        price: parseFloat(data.price?.toString() || '0'),
        targetPrice: parseFloat(data.targetPrice?.toString() || '0'),
        currentSavings: parseFloat(data.currentSavings?.toString() || '0'),
        category: data.category,
        link: data.link,
        image: data.image,
        status: data.status || 'Active',
        userId: user.id,
      },
    });
  }

  async update(supabaseId: string, id: string, data: any) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new Error('User not found');

    return this.prisma.wishlistItem.update({
      where: { id, userId: user.id },
      data: {
        ...data,
        price: data.price != null ? parseFloat(data.price.toString()) : undefined,
        targetPrice: data.targetPrice != null ? parseFloat(data.targetPrice.toString()) : undefined,
        currentSavings: data.currentSavings != null ? parseFloat(data.currentSavings.toString()) : undefined,
      },
    });
  }

  async delete(supabaseId: string, id: string) {
    const user = await this.prisma.user.findUnique({ where: { supabaseId } });
    if (!user) throw new Error('User not found');

    return this.prisma.wishlistItem.delete({
      where: { id, userId: user.id },
    });
  }
}
