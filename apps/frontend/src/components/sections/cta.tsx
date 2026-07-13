import Link from 'next/link';
import { Button } from '@orivastra/ui';
import { SectionWrapper } from '@/components/ui/section-wrapper';
import { Reveal } from '@/components/animations/reveal';

export function CTASection() {
  return (
    <SectionWrapper className="from-primary/5 to-accent/5 bg-gradient-to-br">
      <Reveal direction="down">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
            Ready to Build Something Great?
          </h2>
          <p className="text-muted-foreground mt-4">
            Let&apos;s discuss your project and explore how Orivastra can help bring your vision to
            life.
          </p>
          <div className="mt-8">
            <Button asChild size="lg">
              <Link href="#contact">Start a Project</Link>
            </Button>
          </div>
        </div>
      </Reveal>
    </SectionWrapper>
  );
}
