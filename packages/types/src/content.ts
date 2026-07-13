export interface NavItem {
  label: string;
  href: string;
}

export interface ServiceItem {
  icon: string;
  title: string;
  description: string;
}

export interface TechnologyItem {
  name: string;
  category: string;
  icon?: string;
}

export interface TechnologyCategory {
  name: string;
  items: TechnologyItem[];
}

export interface ProcessStep {
  number: number;
  title: string;
  description: string;
}

export interface RoadmapPhase {
  version: string;
  title: string;
  status: 'completed' | 'current' | 'upcoming';
  features: string[];
}

export interface Stat {
  value: number;
  suffix?: string;
  label: string;
  icon: string;
}

export interface ContactInfo {
  email: string;
  location: string;
  github: string;
  linkedin: string;
  telegram: string;
}
