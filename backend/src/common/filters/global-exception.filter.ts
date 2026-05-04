import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus } from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: any, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const status = exception instanceof HttpException 
      ? exception.getStatus() 
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const message = exception instanceof HttpException 
      ? exception.getResponse() 
      : { message: 'Internal server error', statusCode: status };

    response.status(status).json({
      success: false,
      timestamp: new Date().toISOString(),
      path: ctx.getRequest().url,
      error: typeof message === 'string' ? { message } : message,
    });
  }
}
