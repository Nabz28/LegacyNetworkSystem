# Legacy Network System — Setup Guide

A collaborative network mapping tool for Legacy Bridge Capital. Multiple team
members can edit the same network simultaneously; changes sync in real-time.

---

## 1. Quick local usage (no setup required)

Just open `legacy_network_system.html` in any browser. Data saves to your
browser's `localStorage`. No collaboration — each person has their own copy.

Useful for trying it out, or for each teammate to keep a personal scratch copy.

---

## 2. Full setup — collaborative, deployed on Vercel

### Step 1: Create a Supabase project

1. Go to <https://supabase.com>, sign up / log in
2. Click **New project**
3. Fill in:
   - **Name**: e.g. `lbc-network`
   - **Database password**: (save this somewhere — you won't need it day-to-day but Supabase requires one)
   - **Region**: **Singapore** (closest to Indonesia, lowest latency)
4. Wait ~2 minutes for the project to provision

### Step 2: Create the database schema

1. In your Supabase project dashboard → **SQL Editor** → **New query**
2. Open the file `supabase_schema.sql` from this folder
3. Copy its entire contents into the SQL Editor
4. Click **Run** (or press Cmd/Ctrl + Enter)

You should see "Success. No rows returned." — this created 5 tables and
enabled realtime on all of them.

### Step 3: Grab your API keys

1. In the same Supabase dashboard → **Project Settings** (gear icon, bottom-left) → **API**
2. Copy two values:
   - **Project URL** — looks like `https://abcdefghijk.supabase.co`
   - **anon public key** — a long JWT string starting with `eyJ...`

### Step 4: Configure the HTML file

1. Open `legacy_network_system.html` in a text editor (VS Code, Sublime, etc.)
2. Search for the line:
   ```js
   const SUPABASE_URL = 'YOUR_SUPABASE_URL';
   ```
3. Replace the two placeholders:
   ```js
   const SUPABASE_URL      = 'https://abcdefghijk.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJ...your.anon.key...';
   ```
4. Save.

### Step 5: Push to GitHub

```bash
git init
git add legacy_network_system.html
git commit -m "Initial Legacy Network System"
git remote add origin https://github.com/YOUR_USERNAME/lbc-network.git
git push -u origin main
```

### Step 6: Deploy to Vercel

1. Go to <https://vercel.com/new>
2. Import the GitHub repo you just pushed
3. **Framework preset**: Other (this is a static HTML file)
4. **Build & Output settings**: leave blank / default
5. Click **Deploy**

Vercel gives you a URL like `https://lbc-network.vercel.app`. Share it with your team.

Anyone who opens that URL sees the same live network. Edits from one person
appear on everyone else's screen within ~1 second.

---

## 3. Verifying it works

Open the Vercel URL in two different browser windows (or two devices).
Add a connection in one window. It should appear in the other within a second
or two. The sync indicator next to the "Legacy Bridge Capital" text in the
top-left should read **LIVE** with a green dot.

If the indicator reads **Local only**, Supabase isn't configured — check step 4.
If it reads **Offline**, there's a connection error — open the browser console
(F12) and check for red errors. Most likely causes:
- Typo in `SUPABASE_URL` or `SUPABASE_ANON_KEY`
- Schema not yet run in Supabase SQL Editor
- Realtime not enabled (run step 2 again — the `ALTER PUBLICATION` statements enable it)

---

## 4. Security note

This setup has **no auth** — anyone who knows the Vercel URL can read and
edit the network. The `anon` public key is safe to include in client code
(that's by design — it's gated by the Row-Level Security policies in the DB),
but the default policies in `supabase_schema.sql` allow anyone to read/write.

For a private team tool, the simplest protection is:
- Keep the Vercel URL private (don't share publicly)
- OR password-protect the Vercel deployment (Vercel → Project Settings →
  Deployment Protection → Password)

For tighter security, replace the `allow_all` policies with Supabase Auth
policies. See the [Supabase RLS docs](https://supabase.com/docs/guides/auth/row-level-security).

---

## 5. Making changes later

Just edit `legacy_network_system.html`, commit, push. Vercel auto-deploys on push.

```bash
git add legacy_network_system.html
git commit -m "Tweak sector list"
git push
```

Your Supabase data persists across deployments — you're only redeploying the
frontend code, not the database.

---

## 6. Architecture summary

- **HTML file**: single-page app, D3 force-directed graph, runs entirely in the browser
- **Supabase**: Postgres database + realtime pub/sub
- **State flow**: every user's browser holds the full state in memory. Mutations
  write optimistically to local state, then upsert to Supabase. Supabase
  broadcasts the change via realtime to all connected browsers (including the
  sender, which is a harmless no-op since state already reflects it).
- **localStorage**: used as a fast-start cache — on page load, the browser
  renders from cache immediately, then fetches fresh data from Supabase and
  re-renders.

Categories, sectors, and team members are seeded with LBC defaults the first
time anyone connects to an empty database.
