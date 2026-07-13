import { z } from 'zod';

export const createContactSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  message: z.string().min(10).max(1000),
});

export type CreateContactDto = z.infer<typeof createContactSchema>;
