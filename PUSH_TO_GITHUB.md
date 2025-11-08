# 🚀 Push to GitHub Instructions

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: **dungeon_crawler**
3. Description: **A Lua-based tabletop RPG with procedural dungeons, turn-based combat, and magic**
4. **Public** repository
5. **DO NOT** add README, .gitignore, or license (we have them)
6. Click **Create repository**

## Step 2: Push Your Code

After creating the repository, run these commands:

```bash
cd /Users/csrdsg/dungeon_crawler

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/dungeon_crawler.git

# Push to GitHub
git branch -M main
git push -u origin main --tags
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## Step 3: Create the Release

1. Go to: `https://github.com/YOUR_USERNAME/dungeon_crawler/releases`
2. Click **"Create a new release"**
3. **Choose a tag:** Select `v0.1.0-alpha`
4. **Release title:** `🎲 Dungeon Crawler v0.1.0-alpha - First Alpha Release`
5. **Description:** Copy and paste the content from `RELEASE_NOTES.md`
6. ☑️ **Check "Set as a pre-release"**
7. Click **"Publish release"**

## Step 4: Configure Repository (Optional)

### Add Topics
Under **About** section, add these topics:
- `lua`
- `rpg`
- `dungeon-crawler`
- `tabletop-rpg`
- `procedural-generation`
- `turn-based-combat`
- `game-development`
- `roguelike`

### Enable Features
- ☑️ Issues (for bug reports)
- ☑️ Discussions (for community)
- ☑️ Wiki (optional)

## Step 5: Share Your Release

After publishing, share on:
- r/lua
- r/roguelikedev
- r/proceduralgeneration
- Twitter/social media
- itch.io (optional)

---

**That's it! Your Dungeon Crawler is now live on GitHub! 🎮⭐**
