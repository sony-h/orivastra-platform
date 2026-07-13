import { SectionWrapper } from '@/components/ui/section-wrapper';
import { SectionHeading } from '@/components/ui/section-heading';
import { Reveal } from '@/components/animations/reveal';
import { processSteps } from '@/lib/constants';

export function ProcessSection() {
  return (
    <SectionWrapper id="process">
      <Reveal>
        <SectionHeading
          label="Process"
          title="How We Work"
          description="A structured approach to building reliable software, from discovery to continuous improvement."
        />
      </Reveal>

      <div className="relative mx-auto mt-16 max-w-3xl">
        <div className="bg-border absolute left-4 top-0 h-full w-px lg:left-1/2 lg:-translate-x-px" />

        {processSteps.map((step, i) => {
          const isEven = i % 2 === 0;
          return (
            <Reveal key={step.number} delay={i * 0.15} direction={isEven ? 'left' : 'right'}>
              <div
                className={`relative mb-12 flex gap-6 lg:mb-16 ${
                  isEven ? 'lg:flex-row' : 'lg:flex-row-reverse'
                }`}
              >
                <div className={`flex-1 ${isEven ? 'lg:pr-12 lg:text-right' : 'lg:pl-12'}`}>
                  <h3 className="text-lg font-semibold">{step.title}</h3>
                  <p className="text-muted-foreground mt-1 text-sm">{step.description}</p>
                </div>
                <div className="border-primary bg-background text-primary relative z-10 flex size-8 shrink-0 items-center justify-center rounded-full border-2 text-sm font-bold">
                  {step.number}
                </div>
                <div className="hidden flex-1 lg:block" />
              </div>
            </Reveal>
          );
        })}
      </div>
    </SectionWrapper>
  );
}
