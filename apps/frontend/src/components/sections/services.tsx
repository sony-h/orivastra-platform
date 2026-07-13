import Link from 'next/link';
import { Code2, Cloud, Brain, RefreshCw, Lightbulb } from 'lucide-react';
import { Card } from '@orivastra/ui';
import { SectionWrapper } from '@/components/ui/section-wrapper';
import { SectionHeading } from '@/components/ui/section-heading';
import { Reveal } from '@/components/animations/reveal';
import { services } from '@/lib/constants';

const iconMap: Record<string, React.ElementType> = {
  Code2,
  Cloud,
  Brain,
  RefreshCw,
  Lightbulb,
};

export function ServicesSection() {
  return (
    <SectionWrapper id="services">
      <Reveal>
        <SectionHeading
          label="What We Do"
          title="Comprehensive Technology Services"
          description="From custom software to cloud infrastructure and AI integration, we provide end-to-end technology solutions."
        />
      </Reveal>

      <div className="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {services.map((service, i) => {
          const Icon = iconMap[service.icon] ?? Code2;
          return (
            <Reveal key={service.title} delay={i * 0.1}>
              <Card className="hover:border-primary/30 group flex flex-col p-6 transition-all duration-200 hover:scale-[1.02] hover:shadow-md">
                <div className="bg-accent/10 flex size-12 items-center justify-center rounded-lg">
                  <Icon className="text-accent size-6" />
                </div>
                <h3 className="mt-4 text-lg font-semibold">{service.title}</h3>
                <p className="text-muted-foreground mt-2 flex-1 text-sm">{service.description}</p>
                <Link
                  href="/services"
                  className="text-accent mt-4 text-sm font-medium underline-offset-4 hover:underline"
                >
                  Learn More &rarr;
                </Link>
              </Card>
            </Reveal>
          );
        })}
      </div>
    </SectionWrapper>
  );
}
