import { CheckCircle2, Clock, Circle } from 'lucide-react';
import { Card, Badge } from '@orivastra/ui';
import { SectionWrapper } from '@/components/ui/section-wrapper';
import { SectionHeading } from '@/components/ui/section-heading';
import { Reveal } from '@/components/animations/reveal';
import { roadmapPhases } from '@/lib/constants';

const statusIcon: Record<string, React.ElementType> = {
  completed: CheckCircle2,
  current: Clock,
  upcoming: Circle,
};

const statusBadge: Record<string, { label: string; variant: 'default' | 'secondary' | 'outline' }> =
  {
    completed: { label: 'Completed', variant: 'default' },
    current: { label: 'In Development', variant: 'default' },
    upcoming: { label: 'Upcoming', variant: 'secondary' },
  };

export function RoadmapSection() {
  return (
    <SectionWrapper id="roadmap" className="bg-muted/30">
      <Reveal>
        <SectionHeading
          label="Roadmap"
          title="The Path Forward"
          description="Orivastra is designed to grow. Each version builds upon the last toward a complete engineering ecosystem."
        />
      </Reveal>

      <div className="mt-16 grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
        {roadmapPhases.map((phase, i) => {
          const Icon = statusIcon[phase.status] ?? Circle;
          const badge = statusBadge[phase.status] ?? {
            label: 'Upcoming',
            variant: 'secondary' as const,
          };
          return (
            <Reveal key={phase.version} delay={i * 0.1}>
              <Card
                className={`flex h-full flex-col p-6 ${
                  phase.status === 'current' ? 'border-primary/40 bg-primary/5 shadow-md' : ''
                }`}
              >
                <div className="mb-4 flex items-center justify-between">
                  <Badge variant={badge.variant} className="text-xs">
                    {badge.label}
                  </Badge>
                  <Icon
                    className={`size-4 ${
                      phase.status === 'completed'
                        ? 'text-green-500'
                        : phase.status === 'current'
                          ? 'text-accent'
                          : 'text-muted-foreground'
                    }`}
                  />
                </div>
                <span className="text-muted-foreground text-xs font-medium uppercase tracking-wider">
                  {phase.version}
                </span>
                <h3 className="mt-1 text-lg font-semibold">{phase.title}</h3>
                <ul className="mt-4 flex-1 space-y-2">
                  {phase.features.map((feature) => (
                    <li
                      key={feature}
                      className="text-muted-foreground flex items-start gap-2 text-sm"
                    >
                      <span className="bg-muted-foreground/50 mt-1 block size-1.5 shrink-0 rounded-full" />
                      {feature}
                    </li>
                  ))}
                </ul>
              </Card>
            </Reveal>
          );
        })}
      </div>
    </SectionWrapper>
  );
}
