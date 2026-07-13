import { Controller, Post, Body, HttpCode, HttpStatus, BadRequestException } from '@nestjs/common';
import { ContactService } from './contact.service.js';
import { createContactSchema } from './dto/create-contact.dto.js';

@Controller('api/contact')
export class ContactController {
  constructor(private readonly contactService: ContactService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() body: unknown) {
    const result = createContactSchema.safeParse(body);

    if (!result.success) {
      throw new BadRequestException({
        error: 'Validation failed',
        details: result.error.flatten().fieldErrors,
      });
    }

    await this.contactService.create(result.data);

    return { success: true };
  }
}
