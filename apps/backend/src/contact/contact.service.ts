import { Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import type { CreateContactDto } from './dto/create-contact.dto.js';

@Injectable()
export class ContactService {
  private prisma = new PrismaClient();

  async create(data: CreateContactDto) {
    return this.prisma.contactRequest.create({ data });
  }
}
