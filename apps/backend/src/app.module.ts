import { Module } from '@nestjs/common';
import { ContactModule } from './contact/contact.module.js';
import { HealthModule } from './health/health.module.js';

@Module({
  imports: [ContactModule, HealthModule],
})
export class AppModule {}
