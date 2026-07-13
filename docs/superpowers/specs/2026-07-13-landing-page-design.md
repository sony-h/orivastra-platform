# Landing Page Frontend — Design Spec

**Date:** 2026-07-13
**Version:** 0.1
**Status:** Approved
**Related:** `docs/04_UI_UX_SPEC.md`, `docs/02_PRD.md`, `docs/08_TODO.md`

---

## 1. Overview

Build the complete Orivastra v0.1 landing page — a single-page company profile website with 8 sections, navbar, footer, scroll-triggered animations, and a functional contact form. This is the first user-facing deliverable.

### Success Criteria

- Premium, minimal, spacious UI matching the Apple/Stripe/Vercel aesthetic
- Fully responsive (desktop, tablet, mobile)
- All sections animate on scroll via Framer Motion
- Contact form submits to backend and stores in PostgreSQL
- Lighthouse targets: all >95 (performance, SEO, accessibility, best practices)
- Zero TypeScript errors, zero lint warnings

---

## 2. Scope

### Included

| Item          | Details                                                             |
| ------------- | ------------------------------------------------------------------- |
| Navbar        | Fixed, transparent→solid on scroll, mobile hamburger drawer         |
| Hero          | Animated grid background, headline, sub, 2 CTAs                     |
| About Preview | 2-col: text + animated stat counters                                |
| Services      | 3-col card grid, 5 service categories                               |
| Technologies  | Grouped logo grid with hover tooltips                               |
| Process       | Vertical numbered timeline, 5 steps                                 |
| Roadmap       | Horizontal version cards, current phase highlighted                 |
| CTA           | Gradient section with call-to-action                                |
| Contact       | Form (Name, Email, Message) + contact info cards                    |
| Footer        | 4-column grid, social links, legal                                  |
| 404           | Minimal not-found page                                              |
| SEO           | Sitemap, robots.txt, per-page metadata, OG tags                     |
| Branding      | SVG logo, favicon, OG image                                         |
| Backend       | `POST /api/contact` endpoint with zod validation + Prisma           |
| Animations    | Scroll-triggered reveal on all sections (Framer Motion `useInView`) |

### Excluded

- Inner pages (About, Services, Technologies, Roadmap — separate specs)
- Authentication, CMS, dashboard
- Real project portfolio content
- Blog

---

## 3. File Layout

```
apps/frontend/src/
├── app/
│   ├── globals.css                    (exists — design tokens)
│   ├── layout.tsx                     root layout + Navbar + Footer
│   ├── page.tsx                       homepage — composes 8 sections
│   ├── not-found.tsx                  404 page
│   ├── sitemap.ts                     auto-generated sitemap
│   └── robots.ts                      robots.txt
├── components/
│   ├── layout/
│   │   ├── navbar.tsx                 fixed nav, transparent→solid on scroll
│   │   ├── footer.tsx                 4-column footer grid
│   │   └── mobile-menu.tsx            slide-in mobile nav drawer
│   ├── sections/
│   │   ├── hero.tsx                   headline + sub + CTAs + animated grid bg
│   │   ├── about-preview.tsx          company intro + animated stat counters
│   │   ├── services.tsx               card grid of 5 service categories
│   │   ├── technologies.tsx           grouped tech logos with hover tooltips
│   │   ├── process.tsx                numbered vertical timeline
│   │   ├── roadmap.tsx                version timeline cards
│   │   ├── cta.tsx                    call-to-action gradient section
│   │   └── contact.tsx                form (left) + contact info cards (right)
│   ├── ui/
│   │   ├── section-wrapper.tsx        consistent section padding + reveal animation
│   │   ├── section-heading.tsx        label + title + description pattern
│   │   └── animated-grid.tsx          hero background animated grid (CSS)
│   └── animations/
│       └── reveal.tsx                 framer-motion scroll-reveal wrapper
├── lib/
│   ├── utils.ts                       (exists — cn re-export)
│   └── constants.ts                   site config, nav items, services, tech, etc.
└── hooks/
    └── use-scroll-position.ts         navbar transparency toggle

apps/backend/src/
├── contact/
│   ├── contact.controller.ts          POST /api/contact
│   ├── contact.service.ts             validate + create in DB
│   └── dto/
│       └── create-contact.dto.ts      zod validation schema
├── prisma/
│   └── schema.prisma                  ContactRequest model
└── app.module.ts                      register ContactModule

packages/ui/src/
├── input.tsx                          (new)
├── textarea.tsx                       (new)
├── label.tsx                          (new)
└── tooltip.tsx                        (new)
```

---

## 4. Component Design

### 4.1 Navbar

**Desktop:** Horizontal nav bar, fixed to top. Links: Home, About, Services, Technologies, Roadmap, Contact. "Get in Touch" button (primary variant, links to #contact). At top of page: `bg-transparent`. After scrolling >50px: `bg-background/80 backdrop-blur-md border-b`.

**Mobile:** Hamburger icon (Lucide `Menu` / `X`). Opens `<MobileMenu>` — full-screen slide-in from right with dark overlay. Links stacked vertically with large touch targets. Framer Motion `AnimatePresence` for enter/exit.

**Logo:** Text "Orivastra" in Geist bold (`text-xl font-bold tracking-tight`). SVG geometric mark to the left (a stylized "O" or diamond — created as inline SVG).

**Hooks:** `useScrollPosition()` returns `{ scrollY, isScrolled: boolean }`.

### 4.2 Hero Section

**Background:** `<AnimatedGrid>` component. CSS grid overlay with randomized opacity pulses (0.02–0.06 opacity). Navy lines on white background. Pure CSS animation — no Framer Motion needed for the grid.

**Content (centered, max-w-[720px]):**

1. Eyebrow: `<Badge variant="secondary">Technology Company</Badge>`
2. Headline: `text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight` — "Building Intelligent Digital Solutions" (2 lines)
3. Subheadline: `text-lg text-muted-foreground max-w-xl` — one-line value prop
4. CTAs (flex, gap-4):
   - Primary: `<Button size="lg">Explore Services</Button>` (links to #services)
   - Secondary: `<Button variant="outline" size="lg">Learn More</Button>` (links to #about)

**Animation:** Headline fades in + slides up (300ms), sub and CTAs stagger (100ms delay each). Grid renders immediately.

**Height:** `min-h-[90vh]` with flex centering.

### 4.3 About Preview Section

**Layout:** 2-column grid (`grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16`).

**Left column:**

- `<SectionHeading label="About Us" title="Engineering the Future of Digital Solutions">`
- 2 paragraphs about Orivastra mission and philosophy
- `"Learn More →"` text link (no button, just styled text with underline animation) — links to `/about` (future route)

**Right column:** 3 stat cards stacked vertically (gap-6):

- Each: `<Card>` with `p-6`, icon (Lucide) + counter number + label
- Numbers animate from 0 to target on scroll reveal using Framer Motion `useMotionValue` + `useTransform` + `animate`
- Example stats: 50+ Projects, 15+ Technologies, 5+ Years (placeholder)

**Animation:** Left slides from left, stats stagger from right. Counter animation triggers on reveal.

### 4.4 Services Section

**Layout:** 3-column grid (`grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6`).

**5 Cards** (last row has 2 cards centered, or use 6 cards by splitting a category):

1. Software Engineering
2. Cloud & Infrastructure
3. Artificial Intelligence
4. Digital Transformation
5. Consulting

**Each card (`<Card>` with `p-6`, hover: `scale-[1.02] border-primary/30 shadow-md`, transition 200ms):**

- Lucide icon (size-8, Electric Blue)
- Title: `text-lg font-semibold mt-4`
- Description: `text-sm text-muted-foreground mt-2`
- "Learn More →" link at bottom (links to `/services` — future route)

**Section heading:** "What We Do" / "Comprehensive Technology Services"

### 4.5 Technologies Section

**Layout:** Grouped by category. Each category has a heading + horizontal flex-wrap grid of tech items.

**Categories:** Frontend, Backend, Infrastructure, Cloud, Database, DevOps, AI

**Each tech item:** `<div>` with `border rounded-lg px-4 py-3`, tech name (`text-sm font-medium`), optional Lucide icon. Hover: tooltip with capability description + subtle border color shift.

**Tooltip:** `<Tooltip>` component (from `@orivastra/ui`). Uses Radix `Tooltip` primitive. Content: brief 1-line description of expertise with that technology.

**Animation:** Categories stagger-fade in as groups (not individual items).

### 4.6 Process Section

**Layout:** Vertical timeline. Center-aligned on desktop, left-aligned on mobile.

**5 Steps:** Discovery → Design → Development → Deployment → Iteration

**Each step:**

- Circle number (size-10, border-2, border-primary, flex-center, `text-primary font-bold`)
- Connected by vertical line (`w-px bg-border h-12` between steps)
- Content next to circle: title (`text-lg font-semibold`) + description (`text-sm text-muted-foreground`)
- Alternating left/right layout on desktop (zigzag), stacked on mobile

**Animation:** Each step reveals one at a time (stagger 200ms).

### 4.7 Roadmap Section

**Layout:** Horizontal scrollable card row on mobile (`flex overflow-x-auto snap-x`), grid on desktop (`grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4`).

**5 Cards:**

1. v0.1 — Company Profile **(current — accent border + "In Development" badge)**
2. v0.2 — Portfolio & Blog
3. v0.3 — CMS
4. v1.0 — Orivastra Control
5. v2.0 — AI Platform

**Each card (`<Card>`):**

- Version badge (`<Badge>`: "Current" in primary, others in secondary)
- Title: version number + name
- 3-4 bullet point features (`text-sm text-muted-foreground`)
- Status indicator dot (green = completed, blue = current, gray = upcoming)

**Animation:** Cards fade in from bottom, staggered left to right (100ms each).

### 4.8 CTA Section

**Layout:** Full-width with subtle diagonal gradient background (`bg-gradient-to-br from-primary/5 to-accent/5`). Centered content, `py-24`.

**Content:**

- Headline: "Ready to Build Something Great?" (`text-3xl sm:text-4xl font-bold`)
- Sub: "Let's discuss your project and explore how Orivastra can help." (`text-muted-foreground`)
- CTA: `<Button size="lg">Start a Project</Button>` (links to #contact)

**Animation:** Fade-in + slight scale-up (0.95 → 1) on reveal. 400ms ease-out.

### 4.9 Contact Section

**Layout:** 2-column grid (`grid-cols-1 lg:grid-cols-2 gap-12`).

**Left — Form:**

- Fields: Name (`<Input>`), Email (`<Input type="email">`), Message (`<Textarea rows={4}>`)
- Labels via `<Label>` component
- Client-side validation with zod before submit
- Submit button: `<Button type="submit">` with loading state (`disabled` + spinner icon)
- Success: Replace form with success message ("Thanks! We'll be in touch.")
- Error: Inline error below form (`text-destructive text-sm`)

**Right — Contact Info:**

- 5 info cards stacked vertically:
  - Email: `hello@orivastra.com`
  - GitHub: `/orivastra`
  - LinkedIn: `/company/orivastra`
  - Telegram: `@orivastra`
  - Location: placeholder city
- Each: Lucide icon + label + value (`text-sm`)

### 4.10 Footer

**Layout:** 4 columns on desktop (`grid-cols-2 md:grid-cols-4`), stacked on mobile. `border-t pt-16 pb-8`.

**Columns:**

1. **Company:** Logo + tagline + copyright
2. **Navigation:** Home, About, Services, Technologies, Roadmap, Contact
3. **Connect:** GitHub, LinkedIn, Telegram (with icons, `text-muted-foreground hover:text-foreground`)
4. **Legal:** Privacy Policy, Terms of Service (links to placeholder routes)

**Bottom bar:** `border-t mt-12 pt-8 text-center text-xs text-muted-foreground` — "Built with precision by Orivastra. © 2026. All rights reserved."

### 4.11 404 Page

Minimal centered content: "404" (`text-8xl font-bold text-muted`), "Page Not Found", "Go back home" link. No navbar/footer complexity.

---

## 5. Shared Patterns

### 5.1 `<SectionWrapper>`

```tsx
interface SectionWrapperProps {
  id?: string;
  children: React.ReactNode;
  className?: string;
}
```

Renders a `<section>` with `py-24 lg:py-32`, `max-w-[1280px] mx-auto px-4 sm:px-6 lg:px-8`. Accepts optional `id` for anchor links. Wraps children in `<Reveal>` by default.

### 5.2 `<SectionHeading>`

```tsx
interface SectionHeadingProps {
  label: string;
  title: string;
  description?: string;
}
```

Renders: label (`text-sm font-medium text-accent uppercase tracking-wider`) → title (`text-3xl sm:text-4xl font-bold tracking-tight mt-2`) → optional description (`text-muted-foreground mt-4 max-w-2xl`). Centered by default, `text-left` via prop.

### 5.3 `<Reveal>`

```tsx
interface RevealProps {
  direction?: 'up' | 'down' | 'left' | 'right';
  delay?: number;
  duration?: number;
  once?: boolean;
  children: React.ReactNode;
}
```

Uses `useInView` from framer-motion. `once: true` (animate only first time). `margin: "-100px"`. Checks `prefers-reduced-motion` — if true, renders children without animation. Default: `direction="up"`, `delay=0`, `duration=0.4`.

---

## 6. Data & Constants

### `src/lib/constants.ts`

Single source of truth. All objects typed with `@orivastra/types`:

```ts
export const siteConfig: SiteConfig = {
  name: "Orivastra",
  tagline: "Building Intelligent Digital Solutions for the Future",
  description: "...",
  url: "https://orivastra.com",
  ogImage: "/og-image.png",
  links: { github: "...", linkedin: "...", telegram: "..." },
};

export const navItems: NavItem[] = [
  { label: "Home", href: "#" },
  { label: "About", href: "#about" },
  { label: "Services", href: "#services" },
  { label: "Technologies", href: "#technologies" },
  { label: "Roadmap", href: "#roadmap" },
  { label: "Contact", href: "#contact" },
];

export const services: ServiceItem[] = [...];
export const technologies: TechnologyCategory[] = [...];
export const processSteps: ProcessStep[] = [...];
export const roadmapPhases: RoadmapPhase[] = [...];
export const stats: Stat[] = [...];
export const contactInfo: ContactInfo = { ... };
```

---

## 7. Backend — Contact Endpoint

### Route: `POST /api/contact`

**Controller:** `ContactController` in `apps/backend/src/contact/`

**DTO (zod):**

```ts
{
  name: z.string().min(2).max(100),
  email: z.string().email(),
  message: z.string().min(10).max(1000),
}
```

**Flow:**

1. Validate body with zod
2. If invalid → `400 { error: "Validation failed", details: [...] }`
3. If valid → `ContactService.create(data)` → Prisma insert into `contact_requests`
4. Return `201 { success: true }`

**Prisma Model:**

```prisma
model ContactRequest {
  id        Int      @id @default(autoincrement())
  name      String
  email     String
  message   String
  createdAt DateTime @default(now()) @map("created_at")
  @@map("contact_requests")
}
```

**Module registration:** `ContactModule` imported into `AppModule`.

---

## 8. Branding Assets

### Logo

Inline SVG in navbar, also exported as standalone file:

- Geometric mark: stylized diamond or interlocking "O" shapes, Electric Blue (#2563EB)
- Wordmark: "Orivastra" in Geist Bold
- Saved to `apps/frontend/public/logo.svg`

### Favicon

- 32x32 SVG favicon using the geometric mark only
- Saved to `apps/frontend/public/favicon.svg`
- Referenced in layout metadata

### OG Image

- 1200x630 PNG/SVG with Orivastra logo, tagline, subtle gradient background
- Saved to `apps/frontend/public/og-image.png`
- Referenced in layout metadata `openGraph.images`

---

## 9. Responsive Breakpoints

| Breakpoint          | Layout Changes                                                                          |
| ------------------- | --------------------------------------------------------------------------------------- |
| Mobile (<768px)     | Single column, hamburger nav, smaller headings (`text-3xl` → `text-2xl`), stacked cards |
| Tablet (768-1024px) | 2-column grids where applicable, horizontal nav (if space allows, else hamburger)       |
| Desktop (>1024px)   | Full multi-column layouts, horizontal nav, max-width container                          |

---

## 10. Dependencies

### New Frontend Dependencies

None. All needed packages already installed: `framer-motion`, `lucide-react`, `next`, `react`, `react-dom`.

### New Backend Dependencies

- `zod` (validation)
- `@prisma/client` + `prisma` (database)

### New UI Primitives (`@orivastra/ui`)

- `@radix-ui/react-label`
- `@radix-ui/react-tooltip`

---

## 11. Build Order

1. **Content layer** — `constants.ts` with all typed data
2. **UI primitives** — Input, Textarea, Label, Tooltip in `@orivastra/ui`
3. **Animation system** — `<Reveal>` + `<SectionWrapper>` + `<SectionHeading>`
4. **Layout shell** — Navbar + MobileMenu + Footer + `useScrollPosition`
5. **Sections** — Hero → About → Services → Technologies → Process → Roadmap → CTA → Contact
6. **Homepage assembly** — Compose all sections in `page.tsx`
7. **SEO** — sitemap.ts, robots.ts, metadata updates
8. **404** — not-found.tsx
9. **Branding** — SVG logo + favicon + OG image
10. **Backend** — Prisma schema + ContactModule + endpoint
11. **Verification** — build + lint + typecheck + responsive check

---

## 12. Verification Checklist

- [ ] `pnpm build` passes with zero errors
- [ ] `pnpm lint` passes with zero warnings
- [ ] `pnpm typecheck` passes with zero errors
- [ ] All 8 sections render correctly on desktop (>1024px)
- [ ] Navbar transparency toggle works on scroll
- [ ] Mobile hamburger menu opens/closes
- [ ] All sections responsive (768px, 375px)
- [ ] Scroll animations trigger correctly
- [ ] `prefers-reduced-motion` disables animations
- [ ] Contact form validates client-side
- [ ] Contact form submits successfully (200)
- [ ] Contact form shows errors on invalid input
- [ ] Favicon loads in browser tab
- [ ] OG meta tags present in page source
- [ ] Sitemap accessible at `/sitemap.xml`
- [ ] Lighthouse audit: all categories >95
