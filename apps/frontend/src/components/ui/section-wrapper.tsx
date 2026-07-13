import { cn } from '@/lib/utils';

interface SectionWrapperProps {
  id?: string;
  children: React.ReactNode;
  className?: string;
}

export function SectionWrapper({ id, children, className }: SectionWrapperProps) {
  return (
    <section id={id} className={cn('py-24 lg:py-32', className)}>
      <div className="mx-auto max-w-[1280px] px-4 sm:px-6 lg:px-8">{children}</div>
    </section>
  );
}
