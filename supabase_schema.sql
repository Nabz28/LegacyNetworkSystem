-- ============================================================
-- Legacy Network System — Supabase schema
-- ============================================================
-- Run this ONCE in your Supabase project's SQL Editor.
-- (Supabase Dashboard → SQL Editor → New query → paste → Run)
-- ============================================================

-- Categories (top-level groupings: Finance, Technology, etc.)
CREATE TABLE IF NOT EXISTS categories (
  id          TEXT        PRIMARY KEY,
  name        TEXT        NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Sectors (subcategories of each category)
CREATE TABLE IF NOT EXISTS sectors (
  id          TEXT        PRIMARY KEY,
  name        TEXT        NOT NULL,
  category_id TEXT        REFERENCES categories(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE (name, category_id)
);

-- LBC Team members
CREATE TABLE IF NOT EXISTS members (
  id          TEXT        PRIMARY KEY,
  name        TEXT        NOT NULL,
  role        TEXT,
  image       TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- External connections (the network)
CREATE TABLE IF NOT EXISTS connections (
  id              TEXT        PRIMARY KEY,
  name            TEXT        NOT NULL,
  sector_id       TEXT        REFERENCES sectors(id) ON DELETE SET NULL,
  affiliation     TEXT,
  position        TEXT,
  closeness_index INT         CHECK (closeness_index BETWEEN 1 AND 10),
  known_by        TEXT[]      DEFAULT '{}',
  image           TEXT,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- Company metadata (logos keyed by company name)
CREATE TABLE IF NOT EXISTS company_meta (
  name       TEXT        PRIMARY KEY,
  logo       TEXT,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- Enable Realtime so all connected clients receive live updates
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
ALTER PUBLICATION supabase_realtime ADD TABLE sectors;
ALTER PUBLICATION supabase_realtime ADD TABLE members;
ALTER PUBLICATION supabase_realtime ADD TABLE connections;
ALTER PUBLICATION supabase_realtime ADD TABLE company_meta;

-- ============================================================
-- Row-Level Security (optional — recommended for public sites)
-- ============================================================
-- By default, these tables are wide open: anyone with the anon
-- key can read/write. That is fine for a private tool where
-- the Vercel URL is only shared with your team. If you need
-- stricter access, enable Supabase Auth and replace the
-- "allow all" policies below with auth-checking ones.

ALTER TABLE categories   ENABLE ROW LEVEL SECURITY;
ALTER TABLE sectors      ENABLE ROW LEVEL SECURITY;
ALTER TABLE members      ENABLE ROW LEVEL SECURITY;
ALTER TABLE connections  ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_meta ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all" ON categories   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON sectors      FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON members      FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON connections  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON company_meta FOR ALL USING (true) WITH CHECK (true);
