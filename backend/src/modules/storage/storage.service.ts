import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class StorageService {
  private supabase: SupabaseClient;
  private bucket: string;
  private readonly logger = new Logger(StorageService.name);

  constructor(private configService: ConfigService) {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL')!;
    const serviceKey = this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY')!;
    this.bucket = this.configService.get<string>('SUPABASE_STORAGE_BUCKET')!;
    this.supabase = createClient(supabaseUrl, serviceKey);
  }

  /** Upload a file buffer to Supabase Storage. Returns public URL. */
  async uploadFile(file: Buffer, filePath: string, contentType: string): Promise<string> {
    const { data, error } = await this.supabase.storage
      .from(this.bucket)
      .upload(filePath, file, { contentType, upsert: true });
    if (error) {
      this.logger.error('Supabase upload error', error);
      throw error;
    }
    const { data: { publicUrl } } = this.supabase.storage.from(this.bucket).getPublicUrl(filePath);
    return publicUrl;
  }

  /** Delete a file from Supabase Storage */
  async deleteFile(filePath: string): Promise<void> {
    const { error } = await this.supabase.storage.from(this.bucket).remove([filePath]);
    if (error) {
      this.logger.error('Supabase delete error', error);
      throw error;
    }
  }

  /** Get a signed URL for temporary access */
  async getSignedUrl(filePath: string, expiresIn = 3600): Promise<string> {
    const { data, error } = await this.supabase.storage
      .from(this.bucket)
      .createSignedUrl(filePath, expiresIn);
    if (error) {
      this.logger.error('Supabase signed URL error', error);
      throw error;
    }
    return data?.signedUrl!;
  }
}
