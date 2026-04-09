# Conclusions Slide - Key Takeaways

## Slidev Template

```md
---
layout: default
---

# Conclusions

<div v-click="1">

1. {{takeaway_1}}

</div>

<div v-click="2">

2. {{takeaway_2}}

</div>

<div v-click="3">

3. {{takeaway_3}}

</div>

<div v-click="4" class="future-work">

**Future Directions:** {{future_directions}}

</div>
```

## Content Slots

| Slot | Description | Required |
|------|-------------|----------|
| `takeaway_1` | First key message (most important finding) | Yes |
| `takeaway_2` | Second key message | Yes |
| `takeaway_3` | Third key message | No |
| `future_directions` | Brief next steps or future work | No |

## Usage Notes

- Limit to 3-4 key takeaway messages
- Each takeaway should be a standalone, memorable statement
- Build progressively with v-click for emphasis
- End with future directions to leave the audience with next steps
- Avoid repeating methods; focus on "so what?"
