# Intelligent Inventory Management

## 🎯 Problem Solved

**Without smart inventory management:**
- GitHub Actions runs daily and generates puzzles every time
- Wastes money if users haven't played existing puzzles
- Database fills with unused content
- Cost: ~$0.42/month

**With smart inventory management:**
- Checks inventory before generating
- Only generates when puzzles are actually needed
- Maintains balanced stock across difficulties and themes
- Cost: ~$0.25/month (30-50% savings!)

## 🧠 How It Works

### Every Workflow Run:

```
1. Check Inventory
   ├─ Total puzzles: 87
   ├─ By difficulty: Simple: 30, Medium: 32, Hard: 25
   └─ By theme: Animals: 12, Countries: 11, etc.

2. Check Usage
   ├─ Total plays: 156
   ├─ Completed: 134
   └─ Consumption Rate: 179% (very active users!)

3. Evaluate Rules
   ├─ Is inventory < 30? NO (87 puzzles)
   ├─ Is inventory > 200? NO
   ├─ Is consumption < 20%? NO (179%)
   ├─ Any difficulty < 8? NO
   └─ Any theme < 3? NO

4. Decision: ✅ Generate 14 more puzzles
   (High consumption rate indicates active users)
```

## 📊 Decision Rules

### ❌ SKIP Generation If:

| Check | Threshold | Why |
|-------|-----------|-----|
| Inventory full | ≥ 200 puzzles | Prevent waste and database bloat |
| Low usage | < 20% consumption | Users haven't used existing puzzles |
| Balanced stock | All levels ≥ minimums | Sufficient inventory |

### ✅ GENERATE If:

| Check | Action | Why |
|-------|--------|-----|
| Low total | < 30 puzzles | Need minimum inventory |
| High consumption | ≥ 20% played | Active users need more content |
| Difficulty gap | Any < 8 puzzles | Maintain variety |
| Theme gap | Any < 3 puzzles | Ensure all themes available |

## 🔧 Configuration

Customize thresholds in workflow file:

```yaml
env:
  MIN_PUZZLES: '30'           # Minimum total (generate if below)
  MAX_PUZZLES: '200'          # Maximum total (stop if reached)
  MIN_CONSUMPTION_RATE: '20'  # Generate only if >20% played
  MIN_PER_DIFFICULTY: '8'     # Minimum per difficulty
  MIN_PER_THEME: '3'          # Minimum per theme
```

### Recommended Settings by Stage:

**MVP / Testing (Low users):**
```yaml
MIN_PUZZLES: '20'          # Lower minimum
MAX_PUZZLES: '50'          # Cap inventory
MIN_CONSUMPTION_RATE: '10' # More lenient
```

**Production (Active users):**
```yaml
MIN_PUZZLES: '50'          # Higher minimum
MAX_PUZZLES: '300'         # More capacity
MIN_CONSUMPTION_RATE: '25' # Stricter threshold
```

**High Traffic:**
```yaml
MIN_PUZZLES: '100'
MAX_PUZZLES: '500'
MIN_CONSUMPTION_RATE: '30'
```

## 📈 Real-World Scenarios

### Scenario A: Launch Day (No Users Yet)
```
Day 1:
- Inventory: 0 puzzles
- Usage: 0 plays
- Decision: ✅ Generate 30 puzzles
- Cost: $0.030

Days 2-5 (waiting for users):
- Inventory: 30 puzzles
- Usage: 0 plays (0% consumption)
- Decision: ❌ Skip (low consumption)
- Cost: $0 (saved $0.056!)

Day 6 (first users!):
- Inventory: 30 puzzles
- Usage: 15 plays (50% consumption)
- Decision: ✅ Generate 14 puzzles
- Cost: $0.014
```
**Total Week 1: $0.044** (instead of $0.098)

### Scenario B: Growing User Base
```
Week 1:
- Inventory: 50 puzzles
- Usage: 25 plays (50% consumption)
- Generations: 3/7 days
- Cost: $0.042

Week 4:
- Inventory: 100 puzzles
- Usage: 180 plays (180% consumption - very active!)
- Generations: 6/7 days (high demand)
- Cost: $0.084
```
**Automatically scales with demand!**

### Scenario C: Slow Period
```
Holiday week:
- Inventory: 150 puzzles
- Usage: 20 plays (13% consumption - users on vacation)
- Generations: 1/7 days
- Cost: $0.014

Normal returns:
- Usage jumps to 90 plays (60%)
- System automatically resumes generation
```
**Adapts to user behavior!**

## 💰 Cost Comparison

### Without Inventory Management
```
Daily generation: 14 puzzles/day
Monthly: 14 × 30 = 420 puzzles
Cost: $0.42/month
Waste: Unknown (could be 0-50% unused)
```

### With Inventory Management
```
Smart generation: ~15-20 days/month
Monthly: ~210-280 puzzles
Cost: $0.21-0.28/month
Waste: Minimal (only generates when needed)
Savings: $0.14-0.21/month (33-50%)
```

### Annual Savings
```
Without: $5.04/year
With: $2.52-3.36/year
Savings: $1.68-2.52/year
```

**Over 3 years: Save $5-8!** (Not much, but free is free!)

## 🎮 How to Use

### Automatic Mode (Recommended)
Just let it run! The workflow handles everything:
- Runs daily at 2 AM UTC
- Checks inventory automatically
- Generates only when needed
- No manual intervention required

### Manual Override
Sometimes you want to force generation:

1. Go to GitHub Actions
2. Run workflow manually
3. Set **Force generate** to `true`
4. Useful for:
   - Initial population (generate 50-100 puzzles)
   - Testing
   - Pre-launch inventory buildup

### Monitoring

Check workflow logs to see decisions:

```
✅ Generated puzzles:
  "reason": "low_inventory"
  "generated": 14

❌ Skipped generation:
  "reason": "low_consumption"
  "consumption_rate": "12.5%"
```

## 🔍 Troubleshooting

### "Workflow always skips generation"

**Problem**: `consumption_rate` is low (< 20%)

**Solutions**:
1. Check if users are actually playing puzzles
2. Lower `MIN_CONSUMPTION_RATE` to 10%
3. Use force generate to build initial stock
4. Wait for more user activity

### "Inventory is always at maximum"

**Problem**: `MAX_PUZZLES` set too low

**Solutions**:
1. Increase `MAX_PUZZLES` to 300 or 500
2. If intentional, this prevents overgrowth ✅

### "Some difficulties always low"

**Problem**: Generation not targeting specific difficulty

**Solutions**:
1. Increase `MIN_PER_DIFFICULTY` to 15
2. Check workflow logs - should target low difficulties
3. System should auto-balance over time

## 📚 Technical Details

### Consumption Rate Formula

```javascript
consumptionRate = (totalPlayed / totalPuzzles) × 100

// Examples:
50 plays / 100 puzzles = 50%   (healthy)
200 plays / 100 puzzles = 200% (very active)
10 plays / 100 puzzles = 10%   (low activity)
```

### Decision Priority

1. **Hard Stop**: MAX_PUZZLES reached → Always skip
2. **Usage Check**: consumption < threshold → Skip if inventory adequate
3. **Minimum Check**: inventory < MIN → Always generate
4. **Balance Check**: Check difficulty/theme gaps → Generate targeted
5. **Default**: Healthy inventory → Skip

### Database Queries

Efficient counting queries (no full document reads):

```javascript
// Total puzzles
db.collection('puzzles').count().get()

// By difficulty
db.collection('puzzles')
  .where('difficulty', '==', 'medium')
  .count()
  .get()

// User plays
db.collection('userPuzzles').count().get()
```

**Firestore Cost**: ~10 read operations = FREE (within daily limit)

## ✨ Benefits Summary

✅ **30-50% cost savings** on OpenAI API
✅ **Automatic scaling** with user growth
✅ **Balanced inventory** across all types
✅ **Prevents waste** of unused puzzles
✅ **No manual management** needed
✅ **Adapts to usage patterns** automatically
✅ **Database efficiency** (no bloat)

## 🎯 Best Practices

1. **Start conservative**: Use default settings initially
2. **Monitor logs**: Check first few runs to understand behavior
3. **Adjust thresholds**: Tune based on your user base
4. **Force generate initially**: Build 50-100 puzzle inventory before launch
5. **Let it run**: Trust the system after tuning

---

**Result**: A self-managing puzzle generation system that optimizes costs while ensuring users always have fresh content! 🚀
