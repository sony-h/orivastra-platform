import { Module } from '@nestjs/common';
import { ContactModule } from './contact/contact.module.js';

@Module({
  imports: [ContactModule],
})
export class AppModule {}
