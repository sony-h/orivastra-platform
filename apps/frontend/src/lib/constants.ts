import type {
  NavItem,
  ServiceItem,
  TechnologyCategory,
  ProcessStep,
  RoadmapPhase,
  Stat,
  ContactInfo,
  SiteConfig,
} from '@orivastra/types';

export const siteConfig: SiteConfig = {
  name: 'Orivastra',
  tagline: 'Building Intelligent Digital Solutions for the Future',
  description:
    'Orivastra is a modern technology company specializing in software engineering, cloud infrastructure, AI, and automation. We build premium digital solutions for businesses and organizations.',
  url: 'https://orivastra.com',
  ogImage: '/og-image.svg',
  links: {
    github: 'https://github.com/orivastra',
    linkedin: 'https://linkedin.com/company/orivastra',
    telegram: 'https://t.me/orivastra',
  },
};

export const navItems: NavItem[] = [
  { label: 'Home', href: '#' },
  { label: 'About', href: '#about' },
  { label: 'Services', href: '#services' },
  { label: 'Technologies', href: '#technologies' },
  { label: 'Roadmap', href: '#roadmap' },
  { label: 'Contact', href: '#contact' },
];

export const services: ServiceItem[] = [
  {
    icon: 'Code2',
    title: 'Software Engineering',
    description:
      'Custom web applications, SaaS platforms, REST APIs, and enterprise software built with modern technologies.',
  },
  {
    icon: 'Cloud',
    title: 'Cloud & Infrastructure',
    description:
      'Cloud architecture, Docker containerization, VPS deployment, and infrastructure automation.',
  },
  {
    icon: 'Brain',
    title: 'Artificial Intelligence',
    description:
      'AI integration, intelligent agents, workflow automation, and business process optimization.',
  },
  {
    icon: 'RefreshCw',
    title: 'Digital Transformation',
    description:
      'Modernizing legacy systems, automating manual processes, and enabling digital-first operations.',
  },
  {
    icon: 'Lightbulb',
    title: 'Technology Consulting',
    description:
      'Technical strategy, architecture design, technology selection, and engineering best practices.',
  },
];

export const technologies: TechnologyCategory[] = [
  {
    name: 'Frontend',
    items: [
      { name: 'Next.js', category: 'Frontend' },
      { name: 'React', category: 'Frontend' },
      { name: 'TypeScript', category: 'Frontend' },
      { name: 'Tailwind CSS', category: 'Frontend' },
      { name: 'shadcn/ui', category: 'Frontend' },
    ],
  },
  {
    name: 'Backend',
    items: [
      { name: 'NestJS', category: 'Backend' },
      { name: 'Node.js', category: 'Backend' },
      { name: 'Express', category: 'Backend' },
      { name: 'Python', category: 'Backend' },
    ],
  },
  {
    name: 'Infrastructure',
    items: [
      { name: 'Docker', category: 'Infrastructure' },
      { name: 'Kubernetes', category: 'Infrastructure' },
      { name: 'Nginx', category: 'Infrastructure' },
      { name: 'GitHub Actions', category: 'Infrastructure' },
    ],
  },
  {
    name: 'Cloud',
    items: [
      { name: 'AWS', category: 'Cloud' },
      { name: 'Cloudflare', category: 'Cloud' },
      { name: 'Vercel', category: 'Cloud' },
    ],
  },
  {
    name: 'Database',
    items: [
      { name: 'PostgreSQL', category: 'Database' },
      { name: 'Redis', category: 'Database' },
      { name: 'Prisma', category: 'Database' },
    ],
  },
  {
    name: 'DevOps',
    items: [
      { name: 'CI/CD', category: 'DevOps' },
      { name: 'Git', category: 'DevOps' },
      { name: 'Monitoring', category: 'DevOps' },
    ],
  },
  {
    name: 'AI',
    items: [
      { name: 'OpenAI', category: 'AI' },
      { name: 'DeepSeek', category: 'AI' },
      { name: 'Claude', category: 'AI' },
      { name: 'Hermes', category: 'AI' },
    ],
  },
];

export const processSteps: ProcessStep[] = [
  {
    number: 1,
    title: 'Discovery',
    description:
      'We understand your business goals, technical requirements, and user needs to define the project scope.',
  },
  {
    number: 2,
    title: 'Design',
    description:
      'We create detailed architecture plans, UI/UX designs, and system diagrams aligned with your vision.',
  },
  {
    number: 3,
    title: 'Development',
    description:
      'Our engineers build clean, scalable, and maintainable code following industry best practices.',
  },
  {
    number: 4,
    title: 'Deployment',
    description:
      'We deploy to production using Docker, set up monitoring, and ensure a smooth launch.',
  },
  {
    number: 5,
    title: 'Iteration',
    description:
      'We continuously monitor, optimize, and evolve the product based on feedback and analytics.',
  },
];

export const roadmapPhases: RoadmapPhase[] = [
  {
    version: 'v0.1',
    title: 'Company Profile',
    status: 'current',
    features: ['Landing Page', 'About', 'Services', 'Technologies', 'Contact', 'SEO'],
  },
  {
    version: 'v0.2',
    title: 'Portfolio & Blog',
    status: 'upcoming',
    features: ['Project Gallery', 'Case Studies', 'Technical Blog', 'MDX Articles', 'Search'],
  },
  {
    version: 'v0.5',
    title: 'CMS & Authentication',
    status: 'upcoming',
    features: ['Content Management', 'User Authentication', 'Admin Dashboard', 'Role Management'],
  },
  {
    version: 'v1.0',
    title: 'Orivastra Control',
    status: 'upcoming',
    features: ['Docker Management', 'Server Monitoring', 'Deployment Panel', 'Log Viewer'],
  },
  {
    version: 'v2.0',
    title: 'AI Platform',
    status: 'upcoming',
    features: ['AI Assistant', 'Code Generation', 'Workflow Automation', 'Telegram Integration'],
  },
];

export const stats: Stat[] = [
  { value: 50, suffix: '+', label: 'Projects Delivered', icon: 'FolderGit2' },
  { value: 15, suffix: '+', label: 'Technologies', icon: 'Layers' },
  { value: 5, suffix: '+', label: 'Years Experience', icon: 'Clock' },
];

export const contactInfo: ContactInfo = {
  email: 'hello@orivastra.com',
  location: 'Available Worldwide',
  github: 'https://github.com/orivastra',
  linkedin: 'https://linkedin.com/company/orivastra',
  telegram: 'https://t.me/orivastra',
};
