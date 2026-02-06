# Supabase Local Development Tutorial

A **professional, team-safe guide** for setting up Supabase locally using the Supabase CLI   without permission issues, broken editors, or migration disasters.

---

## 🎯 Goals

* Clean local Supabase setup
* Zero permission headaches
* Migration-safe workflow for teams

---

## 🖥️ Supported Operating Systems

This tutorial applies to:

* **Linux** (covered below ✅)
* **macOS** (to be added later)
* **Windows / WSL** (to be added later)

The workflow, rules, and migration practices are the same across all platforms. Only the installation steps differ.

---

## 🐧 Linux   Supabase CLI Installation

### Download and Install the Supabase CLI Binary

```bash
# Download and install the binary
curl -sL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar -xz
sudo mv supabase /usr/local/bin/
```

### Verify Installation

```bash
supabase --version
```

If the version prints successfully, the Supabase CLI is installed correctly.

> ⚠️ **Note:** Using `sudo` here is acceptable because you are installing a system-wide binary, not running Supabase itself.

---

## 1️⃣ Initialization

Navigate to your project directory and initialize Supabase:

```bash
supabase init
```

This creates the Supabase configuration and prepares your project for local development.

---

## 2️⃣ Starting Supabase & the **No‑Sudo Rule**

Start Supabase from the project directory:

```bash
supabase start
```

> ⚠️ **IMPORTANT   DO NOT USE `sudo`**
>
> If you encounter a permission error, **do not** fix it with `sudo`.
>
> Using `sudo` may look harmless, but it causes long‑term permission damage.

### Why `sudo` Is Dangerous Here

Once you use `sudo` even once:

* New files become owned by **root**
* Over time, your entire project directory becomes root‑owned

#### Common Symptoms

* **VS Code** opens files as *Read‑Only*
* You’re prompted for a password every time you save
* Extensions like **Prettier**, **ESLint**, and linters stop working

---

### 🔑 The SSH Key Problem (GitHub Surprise)

GitHub authentication relies on SSH keys or tokens stored at:

```
/home/YOUR_USER/.ssh
```

| Command         | Which keys are used |
| --------------- | ------------------- |
| `git push`      | Your user SSH keys  |
| `sudo git push` | `/root/.ssh`        |

Root **does not** have your GitHub credentials.

**Result:**

```text
Permission denied (publickey)
```

> 💡 **Moral:** `sudo` fixes the symptom, not the cause.

---

## 3️⃣ The Professional Fix (Docker Permissions)

The *correct* solution is to grant your user access to Docker   **once, properly**.

### Add Your User to the Docker Group

```bash
sudo usermod -aG docker $USER
```

### What This Does

* Adds your user to Docker’s authorized group
* Docker recognizes your permissions automatically
* Eliminates the need for `sudo` entirely

### Apply the Group Change Immediately

```bash
newgrp docker
```

(No logout required 🎉)

### Start Supabase Again

```bash
supabase start
```

Once Supabase starts successfully:

* Copy the **API keys**
* Copy the **service URLs**
* Copy the **storage credentials**

Store them securely.

---

## 4️⃣ Database Migrations

Migrations are **version control for your database schema**.

### Create Your First Migration

```bash
supabase migration new 01_schema
```

---

### 📜 Migration Rules (Read This or Regret It)

#### Initial Setup

* You *may* place **all tables, policies, and rules** in the first migration

#### After Code Is Pushed

* ❌ **Never edit an old migration**
* ✅ **Always create a new migration**

---

### ❓ Why This Matters

**Timeline Example:**

1. **Monday**   You push `01_schema.sql` with an `employees` table
2. **Tuesday**   A teammate pulls the project
3. **Wednesday**   You *edit* `01_schema.sql` to add `departments`
4. **Thursday**   Teammate pulls again

**What happens?**

* Their system says: `01_schema.sql already applied`
* The new changes are skipped

❌ `departments` table never exists on their machine

---

### ✅ The Rule That Saves Teams

> **One change = One new migration file**

Schemas grow **forward**, never rewritten.

---

## 5️⃣ Applying Changes

To rebuild your local database and apply *all* migrations:

```bash
supabase db reset
```

### What This Command Does

* Deletes the local database
* Replays **every migration in order**
* Guarantees schema consistency

---

## 6️⃣ Linking Your Local Project to Supabase Cloud

Now create a **new project on Supabase Cloud** or use one you already have.

> I suggest a **new project**   a clean slate is always easier to reason about.

---

### Get Your Project Reference ID

Open your **Supabase Dashboard** in the browser and look at the URL.

It will look something like this:

```text
https://supabase.com/dashboard/project/abc-def-ghi-jkl
```

👉 `abc-def-ghi-jkl` is your **Project Reference ID**.

---

### Link the Project to Your Local Setup

Run this command in your project directory:

```bash
supabase link --project-ref your-ref-id
```

---

### First-Time CLI Login Error (This Is Normal)

Because this is your first time using the Supabase CLI, you will see this error:

```text
Access token not provided. Supply an access token by running supabase login or setting the SUPABASE_ACCESS_TOKEN environment variable.
```

#### Why This Error Happens

* The **Project Ref** tells the CLI *where* to go
* The **Access Token** tells Supabase *who you are*

Without it, supabase doesn't know who is trying to connect   so Supabase blocks it.

---

### Login to Supabase

```bash
supabase login
```

Your terminal will say something like:

```text
Hello from Supabase!
Press Enter to open browser and login automatically.
Here is your login link in case browser did not open
Enter your verification code:
```

* Press **Enter**
* Your browser will open
* Login to Supabase
* Copy the verification code
* Paste it back into the terminal

That’s it ✅

---

### Link the Project Again

Now run the link command again:

```bash
supabase link --project-ref your-ref-id
```

This time it should work.

---

## 7️⃣ Pushing Local Database Changes to the Cloud

Remember earlier when we created tables locally?

This is **why** I suggested a new cloud project.

Right now:

* Your **local dev database** has tables
* Your **cloud project** is completely empty

So we push our local database changes to the cloud:

```bash
supabase db push
```

Now your cloud project has the same tables defined in your `.sql` migration files.

---

## 8️⃣ Pulling Changes from Cloud to Local

What if a teammate changes something and pushes it to the cloud?

We pull those changes back to local using:

```bash
supabase db pull
```

This keeps everyone in sync.

---

## ⚠️ Common `db pull` Error (And How to Fix It)

Sometimes you may see an error like this:

```text
Diffing schemas...
failed to connect to postgres: failed to connect to `host=aws-1-ap-south-1.pooler.supabase.com user=cli_login_postgres.ref_id database=postgres`:
server error (FATAL: Authentication error, reason: "Unsupported or invalid secret format", context: Handshake (SQLSTATE XX000))
Try rerunning the command with --debug to troubleshoot the error.
```

### Don’t Panic   This Is Common

When you run `db pull`, the CLI talks to your **Cloud database**.

By default, it uses the **Supabase Pooler** (`pooler.supabase.com`).

#### The Problem

* The Pooler sometimes struggles with **CLI login credentials**
* This can happen due to strict project settings or AWS region handshake issues (like `ap-south-1`)

#### The Result

* Your token is rejected
* Even though you just logged in

---

### Solution 1: Use a Direct Database URL

Get your **Connection String** from:

> Supabase Dashboard → Settings → Database

Then run:

```bash
supabase db pull --db-url "postgresql://postgres:[YOUR-PASSWORD]@db.ref_id.supabase.co:5432/postgres"
```

---

### Solution 2: Just Try Again 😄

Sometimes… the second time *is* the charm:

```bash
supabase db pull
```

---

## ✅ Final Result

Your Supabase local + cloud setup is now:

* Clean
* Correct
* Permission‑safe
* Cloud‑synced
* Team‑friendly

Happy building 🚀
