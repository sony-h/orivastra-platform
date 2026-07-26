import { cn } from '@/lib/utils';

interface SectionWrapperProps {
  id?: string;
  children: React.ReactNode;
  className?: string;
}

export function SectionWrapper({ id, children, className }: SectionWrapperProps) {
  return (
    <section id={id} className={cn('py-24 lg:py-32', className)}>
      <div className="mx-auto max-w-[1280px] px-5 sm:px-8 lg:px-10">{children}</div>
    </section>
  );
}
