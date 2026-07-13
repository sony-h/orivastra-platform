'use client';

import { useState } from 'react';
import { Mail, MapPin, Github, Linkedin, Send } from 'lucide-react';
import { Button, Input, Textarea, Label } from '@orivastra/ui';
import { SectionWrapper } from '@/components/ui/section-wrapper';
import { SectionHeading } from '@/components/ui/section-heading';
import { Reveal } from '@/components/animations/reveal';
import { contactInfo } from '@/lib/constants';

interface FormState {
  success: boolean;
  error: string | null;
  loading: boolean;
}

const contactItems = [
  { icon: Mail, label: 'Email', value: contactInfo.email, href: `mailto:${contactInfo.email}` },
  { icon: MapPin, label: 'Location', value: contactInfo.location },
  { icon: Github, label: 'GitHub', value: 'orivastra', href: contactInfo.github },
  { icon: Linkedin, label: 'LinkedIn', value: 'Orivastra', href: contactInfo.linkedin },
  { icon: Send, label: 'Telegram', value: '@orivastra', href: contactInfo.telegram },
];

export function ContactSection() {
  const [form, setForm] = useState({ name: '', email: '', message: '' });
  const [state, setState] = useState<FormState>({ success: false, error: null, loading: false });
  const [errors, setErrors] = useState<Record<string, string>>({});

  function validate() {
    const errs: Record<string, string> = {};
    if (form.name.trim().length < 2) errs.name = 'Name must be at least 2 characters';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) errs.email = 'Valid email is required';
    if (form.message.trim().length < 10) errs.message = 'Message must be at least 10 characters';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validate()) return;

    setState({ success: false, error: null, loading: true });

    try {
      const res = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      });

      if (!res.ok) {
        const data = (await res.json()) as { error?: string };
        throw new Error(data.error ?? 'Something went wrong');
      }

      setState({ success: true, error: null, loading: false });
      setForm({ name: '', email: '', message: '' });
    } catch (err) {
      setState({
        success: false,
        error: err instanceof Error ? err.message : 'Failed to send',
        loading: false,
      });
    }
  }

  return (
    <SectionWrapper id="contact">
      <Reveal>
        <SectionHeading
          label="Contact"
          title="Get in Touch"
          description="Have a project in mind? We'd love to hear from you."
        />
      </Reveal>

      <div className="mt-16 grid gap-12 lg:grid-cols-2">
        <Reveal direction="left">
          {state.success ? (
            <div className="bg-card flex flex-col items-center justify-center rounded-xl border p-12 text-center">
              <div className="flex size-16 items-center justify-center rounded-full bg-green-100">
                <Mail className="size-8 text-green-600" />
              </div>
              <h3 className="mt-6 text-xl font-semibold">Message Sent!</h3>
              <p className="text-muted-foreground mt-2">
                Thanks for reaching out. We&apos;ll get back to you shortly.
              </p>
            </div>
          ) : (
            <form
              onSubmit={(e) => {
                void handleSubmit(e);
              }}
              className="space-y-5"
            >
              <div>
                <Label htmlFor="name">Name</Label>
                <Input
                  id="name"
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  placeholder="Your name"
                  className="mt-1.5"
                />
                {errors.name && <p className="text-destructive mt-1 text-sm">{errors.name}</p>}
              </div>
              <div>
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                  placeholder="you@example.com"
                  className="mt-1.5"
                />
                {errors.email && <p className="text-destructive mt-1 text-sm">{errors.email}</p>}
              </div>
              <div>
                <Label htmlFor="message">Message</Label>
                <Textarea
                  id="message"
                  rows={4}
                  value={form.message}
                  onChange={(e) => setForm({ ...form, message: e.target.value })}
                  placeholder="Tell us about your project..."
                  className="mt-1.5"
                />
                {errors.message && (
                  <p className="text-destructive mt-1 text-sm">{errors.message}</p>
                )}
              </div>
              {state.error && <p className="text-destructive text-sm">{state.error}</p>}
              <Button type="submit" disabled={state.loading} className="w-full">
                {state.loading ? 'Sending...' : 'Send Message'}
              </Button>
            </form>
          )}
        </Reveal>

        <Reveal direction="right">
          <div className="space-y-4">
            {contactItems.map((item, i) => {
              const Icon = item.icon;
              const content = (
                <div className="hover:bg-accent/5 flex items-start gap-4 rounded-lg border p-4 transition-colors">
                  <div className="bg-accent/10 flex size-10 shrink-0 items-center justify-center rounded-lg">
                    <Icon className="text-accent size-5" />
                  </div>
                  <div>
                    <p className="text-sm font-medium">{item.label}</p>
                    <p className="text-muted-foreground text-sm">{item.value}</p>
                  </div>
                </div>
              );

              return (
                <Reveal key={item.label} delay={i * 0.1} direction="right">
                  {item.href ? (
                    <a href={item.href} target="_blank" rel="noopener noreferrer">
                      {content}
                    </a>
                  ) : (
                    content
                  )}
                </Reveal>
              );
            })}
          </div>
        </Reveal>
      </div>
    </SectionWrapper>
  );
}
