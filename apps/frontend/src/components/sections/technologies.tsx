import { Card } from '@orivastra/ui';
import { Tooltip, TooltipProvider } from '@orivastra/ui';
import { SectionWrapper } from '@/components/ui/section-wrapper';
import { SectionHeading } from '@/components/ui/section-heading';
import { Reveal } from '@/components/animations/reveal';
import { technologies } from '@/lib/constants';

export function TechnologiesSection() {
  return (
    <SectionWrapper id="technologies" className="bg-muted/30">
      <Reveal>
        <SectionHeading
          label="Technologies"
          title="Built With Modern Technology"
          description="We choose technologies based on maintainability, scalability, and long-term support."
        />
      </Reveal>

      <TooltipProvider>
        <div className="mt-16 space-y-10">
          {technologies.map((category, ci) => (
            <Reveal key={category.name} delay={ci * 0.1}>
              <div>
                <h3 className="text-muted-foreground mb-4 text-sm font-medium uppercase tracking-wider">
                  {category.name}
                </h3>
                <div className="flex flex-wrap gap-3">
                  {category.items.map((tech) => (
                    <Tooltip key={tech.name} content={`Expertise in ${tech.name}`}>
                      <Card className="hover:border-primary/30 hover:bg-accent/5 cursor-default px-4 py-3 transition-colors">
                        <span className="text-sm font-medium">{tech.name}</span>
                      </Card>
                    </Tooltip>
                  ))}
                </div>
              </div>
            </Reveal>
          ))}
        </div>
      </TooltipProvider>
    </SectionWrapper>
  );
}
