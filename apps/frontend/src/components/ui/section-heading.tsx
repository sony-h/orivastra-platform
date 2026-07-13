interface SectionHeadingProps {
  label: string;
  title: string;
  description?: string;
  align?: 'center' | 'left';
}

export function SectionHeading({
  label,
  title,
  description,
  align = 'center',
}: SectionHeadingProps) {
  return (
    <div className={align === 'center' ? 'mx-auto max-w-2xl text-center' : 'max-w-2xl'}>
      <span className="text-accent text-sm font-medium uppercase tracking-wider">{label}</span>
      <h2 className="mt-2 text-3xl font-bold tracking-tight sm:text-4xl">{title}</h2>
      {description && <p className="text-muted-foreground mt-4">{description}</p>}
    </div>
  );
}
