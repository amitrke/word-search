# Puzzle Generator Setup

This directory contains the GitHub Actions puzzle generation script.

## ✅ Files Created

- `generate-puzzles.js` - Main puzzle generation script with smart inventory management
- `package.json` - Node.js dependencies
- `../../.github/workflows/generate-puzzles.yml` - GitHub Actions workflow

## 🚀 Next Steps

### 1. Install Dependencies Locally (Optional - for testing)

```bash
cd scripts/puzzle-generator
npm install
```

This will create `package-lock.json` which GitHub Actions will use for faster caching.

### 2. Commit and Push to GitHub

```bash
# From project root
git add .github/workflows/generate-puzzles.yml
git add scripts/puzzle-generator/
git commit -m "feat: add GitHub Actions puzzle generator with smart inventory"
git push
```

### 3. Verify Secrets are Set

Go to your GitHub repository:
1. Click **Settings** → **Secrets and variables** → **Actions**
2. Verify these secrets exist:
   - ✅ `OPENAI_API_KEY`
   - ✅ `FIREBASE_SERVICE_ACCOUNT`

### 4. Run Your First Generation

#### Option A: Manual Trigger (Recommended for First Run)

1. Go to your GitHub repository
2. Click the **Actions** tab
3. Click **Generate Word Search Puzzles** workflow
4. Click **Run workflow** button
5. Configure:
   - Number of puzzles: `30` (build initial inventory)
   - Theme: leave empty (all themes)
   - Force generate: `true` (ignore inventory checks for first run)
6. Click green **Run workflow**
7. Wait 10-15 minutes
8. Click on the running workflow to watch logs

#### Option B: Wait for Automatic Run

- Workflow runs daily at 2 AM UTC automatically
- Will check inventory and generate if needed

### 5. Check Firebase Console

After workflow completes:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Firestore Database**
4. Check the `puzzles` collection
5. You should see 30+ puzzles!

## 🧪 Local Testing (Optional)

To test locally before pushing:

```bash
# Set environment variables (Windows)
set OPENAI_API_KEY=your-key-here
set FIREBASE_SERVICE_ACCOUNT={"type":"service_account",...}
set PUZZLE_COUNT=2
set FORCE_GENERATE=true

# Run script
node generate-puzzles.js
```

```bash
# Set environment variables (Mac/Linux)
export OPENAI_API_KEY=your-key-here
export FIREBASE_SERVICE_ACCOUNT='{"type":"service_account",...}'
export PUZZLE_COUNT=2
export FORCE_GENERATE=true

# Run script
node generate-puzzles.js
```

## 📊 What the Script Does

1. **Connects to Firebase** - Using service account credentials
2. **Checks Inventory** - Counts existing puzzles and usage
3. **Calculates Consumption Rate** - How many puzzles users have played
4. **Decides Whether to Generate**:
   - ✅ Generate if inventory < 30 puzzles
   - ✅ Generate if consumption rate > 20%
   - ✅ Generate if any difficulty/theme is low
   - ❌ Skip if inventory is full (200+)
   - ❌ Skip if consumption is low (<20%)
5. **Generates Puzzles** - Calls OpenAI ChatGPT API
6. **Places Words in Grid** - Custom algorithm
7. **Saves to Firestore** - Stores puzzles in database
8. **Logs Results** - Creates `generation-log.json`

## 🎯 Expected Output

### Successful Run

```
🎮 Word Search Puzzle Generator
================================

✓ Firebase Admin initialized
✓ OpenAI initialized

📊 Checking puzzle inventory...

  Inventory Status:
    Total puzzles: 0
    By difficulty: Simple: 0, Medium: 0, Hard: 0

  Usage Statistics:
    Total plays: 0
    Completed: 0
    Consumption rate: 0.0%

  Puzzles by theme:
    Animals: 0
    Countries: 0
    ...

🤔 Evaluating generation need...

  ✅ Inventory low (0/30 puzzles)
  → Generating 30+ puzzles

Configuration:
  Target puzzles: 30
  Themes: Animals, Countries, Technology, Food, Sports, Music, Nature, Movies, Science, History
  Difficulties: simple, medium, hard
  Reason: low_inventory

[1/30] Animals - simple...
  Generated 6 words for Animals (simple)
  ✓ Saved to Firestore: abc123xyz
  ✓ Words placed: 6

[2/30] Animals - medium...
  ...

================================
Summary:
  ✓ Successful: 30
  ✗ Failed: 0
  ⏱ Duration: 145.3s
================================
```

### Skipped Run (Healthy Inventory)

```
🎮 Word Search Puzzle Generator
================================

✓ Firebase Admin initialized
✓ OpenAI initialized

📊 Checking puzzle inventory...

  Inventory Status:
    Total puzzles: 87
    By difficulty: Simple: 30, Medium: 32, Hard: 25

  Usage Statistics:
    Total plays: 12
    Completed: 10
    Consumption rate: 13.8%

🤔 Evaluating generation need...

  ❌ Low consumption rate (13.8% < 20%)
  → Users haven't played enough existing puzzles yet

================================
Reason: low_consumption
No puzzles generated. Exiting.
================================
```

## 🔧 Configuration

You can adjust thresholds in `.github/workflows/generate-puzzles.yml`:

```yaml
env:
  MIN_PUZZLES: '30'           # Minimum total puzzles
  MAX_PUZZLES: '200'          # Maximum total puzzles
  MIN_CONSUMPTION_RATE: '20'  # Only generate if >20% played
  MIN_PER_DIFFICULTY: '8'     # Minimum per difficulty
  MIN_PER_THEME: '3'          # Minimum per theme
```

## 🐛 Troubleshooting

### "FIREBASE_SERVICE_ACCOUNT not found"
- Check GitHub secret is set correctly
- Ensure you pasted the entire JSON

### "OPENAI_API_KEY invalid"
- Verify API key in GitHub secrets
- Check OpenAI account has credits

### "Permission denied" on Firestore
- Verify service account has Firestore write permissions
- Check Firebase security rules allow writes from server

### Workflow doesn't run
- Check workflow file is in `.github/workflows/`
- Verify you pushed to main/master branch
- Check Actions tab for errors

## 📚 Learn More

- [Full Documentation](../../docs/GITHUB_ACTIONS_SETUP.md)
- [Inventory Management](../../docs/INVENTORY_MANAGEMENT.md)
- [Architecture Comparison](../../docs/ARCHITECTURE_COMPARISON.md)

## 💰 Cost

With smart inventory management:
- **$0.25-0.35/month** (OpenAI API only)
- **30-50% savings** compared to always generating
- **FREE Firebase** (Spark plan)

---

**Status**: ✅ Ready to run!
