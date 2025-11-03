# Smart Puzzle Generation System

## Overview

The puzzle generation system has been enhanced with intelligent inventory management that analyzes user progress and generates puzzles where they're needed most. This prevents waste of API costs and ensures users always have fresh puzzles at the levels they're actively playing.

## How It Works

### 1. **Inventory Analysis** 📊
The system checks:
- Total puzzles in the database
- Puzzles per individual level (1-30)
- Puzzles by difficulty (simple, medium, hard)
- Puzzles by theme

### 2. **User Progress Analysis** 👥
The system analyzes:
- Where users are currently positioned (current level)
- Which levels have the most active users
- Recent puzzle activity (last 7 days) by level
- User progression patterns

### 3. **Smart Prioritization** 🎯
Puzzles are generated based on a priority score that considers:

| Priority | Condition | Score |
|----------|-----------|-------|
| **Critical** | Level has < 2 puzzles | +100 |
| **High** | Users active at level + low inventory | +50-100 |
| **High** | Recent plays + low inventory | +40-80 |
| **Medium** | Below target (5 puzzles) | +20 |
| **Skip** | Already at maximum (10 puzzles) | 0 |

### 4. **Generation Limits** 🚦
- **Max per run**: 10-15 puzzles (prevents excessive API costs)
- **Min per level**: 2 puzzles (critical threshold)
- **Target per level**: 5 puzzles (healthy inventory)
- **Max per level**: 10 puzzles (stop generating)

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MAX_PUZZLES_PER_RUN` | 15 | Maximum puzzles to generate in one run |
| `MIN_PER_LEVEL` | 2 | Minimum puzzles per level (critical) |
| `TARGET_PER_LEVEL` | 5 | Target puzzles per level (ideal) |
| `MAX_PER_LEVEL` | 10 | Maximum puzzles per level (ceiling) |
| `MIN_PUZZLES` | 60 | Minimum total puzzles (2 × 30 levels) |
| `MAX_PUZZLES` | 300 | Maximum total puzzles (10 × 30 levels) |
| `MIN_CONSUMPTION_RATE` | 20 | Minimum % of puzzles played before generating more |

## Example Scenarios

### Scenario 1: New App
```
Status: 0 total puzzles, 0 users
Action: Generate 15 puzzles for levels 1-3 (where new users start)
Reason: Critical low inventory at beginner levels
```

### Scenario 2: Active Users at Level 5
```
Status: Level 5 has 2 puzzles, 10 users currently playing level 5
Action: Generate 3 puzzles for level 5
Reason: High user activity + low inventory (priority: 150)
```

### Scenario 3: Well-Stocked App
```
Status: All levels have 5+ puzzles, balanced user distribution
Action: Skip generation
Reason: All levels have sufficient inventory
```

### Scenario 4: Users Progressing Fast
```
Status: Levels 8-12 show high recent activity, but only 2-3 puzzles each
Action: Generate 2-3 puzzles each for levels 8-12
Reason: Active progression + below target inventory
```

## GitHub Actions Workflow

### Automatic Schedule
- Runs daily at 2 AM UTC
- Automatically analyzes and generates needed puzzles
- Maximum 15 puzzles per run to control costs

### Manual Trigger
You can manually trigger puzzle generation with options:
- **Puzzle Count**: How many puzzles to generate (max 15)
- **Theme Filter**: Generate only specific theme (or empty for all)
- **Level Filter**: Target specific levels (or empty for smart selection)
- **Force Generate**: Skip inventory checks

## Smart Features

### 1. **Progressive Allocation**
- Focuses on levels where users are actively playing
- Avoids generating puzzles for rarely-played levels
- Ensures beginners (levels 1-5) always have puzzles

### 2. **Cost Efficiency**
- Limits to 15 puzzles per run (≈$0.30 in API costs)
- Daily runs = max $9/month in generation costs
- Only generates when consumption rate > 20%

### 3. **User-Centric**
- Prioritizes levels with most users
- Tracks recent activity (7-day window)
- Prevents users from running out of puzzles

### 4. **Balanced Inventory**
- Maintains 2-10 puzzles per level
- Target of 5 puzzles per level (sweet spot)
- Stops generating once max is reached

## Monitoring

### Generation Logs
Each run produces a `generation-log.json` with:
- Puzzles generated per level
- Priority scores and reasons
- User distribution snapshot
- Recent activity analysis
- Success/failure status

### Dashboard Metrics
Monitor these key indicators:
- **Puzzles by Level**: Should be 2-10 per level
- **User Distribution**: Where users are currently
- **Consumption Rate**: % of puzzles played
- **Generation Frequency**: How often runs generate puzzles

## Cost Analysis

### Before (Old System)
- Generated 30 puzzles per run (manual)
- No consideration of user needs
- Wasted API calls on rarely-played levels
- Cost: ~$0.60 per run

### After (Smart System)
- Generates 10-15 puzzles per run (average 12)
- Focused on active levels
- Skips runs when inventory is healthy
- Cost: ~$0.24 per run (60% reduction)

**Monthly Savings**: ~$10-15 in API costs while providing better user experience!

## Troubleshooting

### No Puzzles Generated
**Possible reasons**:
1. All levels have sufficient inventory (5+ puzzles)
2. Low consumption rate (< 20% of puzzles played)
3. Maximum inventory reached (300 total puzzles)

**Solution**: Check logs, verify user activity, consider force generation if needed

### Too Many Puzzles for One Level
**Possible reasons**:
1. High user concentration at one level
2. Recent surge in activity

**Solution**: System will auto-balance in next runs. Max per level is capped at 10.

### Missing Puzzles for Advanced Levels
**Possible reasons**:
1. No users have reached those levels yet
2. Priority system focuses on active levels first

**Solution**: Run with `LEVEL_FILTER=15-20` to manually seed advanced levels

## Best Practices

1. **Let it run automatically** - Daily runs will keep inventory balanced
2. **Monitor user progress** - Watch where users are getting stuck
3. **Check consumption rate** - If low, investigate user retention
4. **Review generation logs** - Understand what's being generated and why
5. **Adjust thresholds** - Tune `MIN/TARGET/MAX_PER_LEVEL` based on your user base

## Future Enhancements

- [ ] Difficulty-based prioritization (e.g., prefer medium over hard for most users)
- [ ] Theme popularity tracking (generate more of popular themes)
- [ ] Seasonal themes (holidays, events)
- [ ] A/B testing different puzzle configurations
- [ ] Predictive generation (anticipate where users will be next week)
