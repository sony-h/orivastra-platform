import Link from 'next/link';
import { Button } from '@orivastra/ui';

export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-4">
      <span className="text-muted-foreground/20 text-8xl font-bold">404</span>
      <h1 className="mt-6 text-2xl font-semibold">Page Not Found</h1>
      <p className="text-muted-foreground mt-2">
        The page you&apos;re looking for doesn&apos;t exist.
      </p>
      <Button asChild className="mt-8">
        <Link href="/">Go back home</Link>
      </Button>
    </div>
  );
}
