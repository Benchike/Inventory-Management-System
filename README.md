# Kiru Energy — Inventory Management System

A shared, live inventory system for Kiru Energy: stock catalogue, purchase orders (stock in),
material requisitions (stock out), signed approvals, and downloadable inventory reports.

Everyone signed in sees the same data, updated live.

---

## What you need

Two free accounts:

1. **Supabase** — holds the data (https://supabase.com)
2. **Vercel** — hosts the app (https://vercel.com)

Total setup time: about 15 minutes. No coding required.

---

## Step 1 — Create the database (Supabase)

1. Go to https://supabase.com and create an account, then click **New project**.
   - Name: `kiru-inventory`
   - Database password: choose a strong one and save it somewhere safe
   - Region: pick the closest (e.g. EU West or your preferred region)
2. Wait for the project to finish provisioning (about 2 minutes).
3. In the left sidebar open **SQL Editor** → **New query**.
4. Open the file `schema.sql` from this folder, copy **all** of it, paste it into the editor, and click **Run**.
   You should see "Success. No rows returned." This creates the tables, the stock-update logic and the security rules.

## Step 2 — Get your two keys

1. In Supabase open **Project Settings** (gear icon) → **API**.
2. Copy the **Project URL** — it looks like `https://abcdefgh.supabase.co`
3. Copy the **anon public** key — a long string starting with `eyJ...`

> The anon key is safe to put in the app. Row-level security is switched on, so only
> signed-in team members can read or write anything.

## Step 3 — Put the keys into the app

Open `index.html` in any text editor. Near the top you'll find:

```js
window.KIRU_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-ANON-KEY"
};
```

Replace both values with what you copied in Step 2. Save the file.

## Step 4 — Create team accounts

In Supabase go to **Authentication** → **Users** → **Add user** → **Create new user**.

Create one account per team member (email + password), and tick **Auto Confirm User**
so they can sign in immediately. Anyone without an account cannot see the data.

To add someone later, repeat this step — no redeployment needed.

## Step 5 — Deploy to Vercel

**Easiest route (drag and drop):**

1. Go to https://vercel.com and sign in.
2. Click **Add New** → **Project** → **Deploy** (or visit https://vercel.com/new).
3. Choose the **Deploy from a folder / template** option and drag this whole folder in.
4. Click **Deploy**. After about a minute you get a live URL such as
   `https://kiru-inventory.vercel.app`.

**Via GitHub (recommended if you'll make changes):**

1. Create a new GitHub repository and upload these files (`index.html`, `vercel.json`, `schema.sql`, `README.md`).
2. In Vercel, click **Add New** → **Project** → **Import Git Repository** and pick that repo.
3. Framework preset: **Other**. Leave build settings empty — it's a static site.
4. Click **Deploy**.

Now share the URL with the team. Each person signs in with the account you created for them.

---

## Using it day to day

**Stock Items** — build the catalogue: name, SKU, category, unit, unit cost and a reorder
level that drives the OK / LOW / OUT status.

**Purchase Orders** — adds stock. Create the order, then press **Receive** when the goods
arrive; that is the moment quantities increase and unit costs update.

**Requisitions** — removes stock. Create the requisition, then press **Issue** when materials
leave the store. Availability is shown per line and you're warned if stock is short.

**Sign-off** — an approver name, title and uploaded signature are required before any purchase
order or requisition can be saved. The document also records the account that raised it, so
approvals are traceable across the team.

**Inventory Report** — pick a date range for opening balance, receipts, issues, closing balance
and closing value per item, plus a movement log referencing each document.

**Downloads** — every document and report downloads through your browser's print dialog:
choose **Save as PDF**. Text stays selectable and searchable. Turn on **Background graphics**
in the print options so the brand colours come through.

---

## Notes

- The green dot beside your email means live sync is connected; amber means it's reconnecting.
- Stock changes run as a single database operation, so two people acting at once cannot
  corrupt quantities.
- Document numbers (`KIRU-PO-…`, `KIRU-MRO-…`) are issued by the database, so they never
  collide even if several people create documents simultaneously.
- Supabase's free tier backs up your data; the CSV and JSON exports on the **Team & data**
  tab are for your own records.
- Deleting a stock item does not delete past documents; they keep their history.

## Troubleshooting

**"This app is not configured yet"** — the keys in Step 3 weren't saved, or the file wasn't
redeployed after editing. Re-check `KIRU_CONFIG` and deploy again.

**"Invalid login credentials"** — the user doesn't exist yet. Create them in Supabase →
Authentication → Users, with **Auto Confirm User** ticked.

**Data doesn't appear / amber dot** — confirm `schema.sql` ran without errors, and that the
project URL is correct.
