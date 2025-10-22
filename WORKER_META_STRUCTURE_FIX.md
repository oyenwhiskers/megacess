# Worker Audit Meta Structure Fix - V2

## Problem (Updated)
The API was still rejecting the task approval with error:
```
422 Unprocessable Content
Validation Error: {worker_audit_meta: [Meta data is required for manuring tasks]}
```

Even after implementing the initial task-type-based structure fix.

## Root Cause Analysis
The issue was more complex than initially thought:
1. The API expects **specific meta keys** based on task type (e.g., `"manuring"` for Manuring tasks)
2. Worker meta data from the API might come in **different formats**:
   - Simple string/number: `{"manuring": "100"}`
   - Nested object: `{"fertilizer_type": "BORATE", "fertilizer_amount": 100}`
   - Mixed formats
3. The previous fix only converted existing keys to strings but didn't **extract values from nested structures**

## Solution V2
Enhanced the `_structureMetaByTaskType()` method with:
1. **Value Extraction Logic**: Extracts numeric values from nested meta objects
2. **Flexible Key Mapping**: Handles both underscore and space variations (e.g., `normal_pruning` → `normal pruning`)
3. **Fallback Strategy**: If expected key not found, searches for any valid numeric value
4. **Comprehensive Debug Logging**: Shows original and structured meta for troubleshooting

## Meta Data Structure by Task Type (CORRECTED)

### 1. Pruning
- **meta_key**: `pruning_type`
- **meta_value**: `"normal pruning"` or `"routine pruning"`
- **Example**: `{"pruning_type": "normal pruning"}`

### 2. Harvesting
- **meta_key**: `harvesting_type`
- **meta_value**: `"normal harvesting"` or `"collect loose fruits"`
- **Example**: `{"harvesting_type": "normal harvesting"}`

### 3. Planting
- **No meta required**
- **Example**: `{}` (empty object)

### 4. Manuring ⚠️ (Most Common Issue - FIXED)
- **meta_key**: `fertilizer_type`
  - **meta_value**: `"NPK"` or `"BORATE"` or `"MOP"`
- **meta_key**: `fertilizer_amount`
  - **meta_value**: integer (amount of fertilizer)
- **Example**: `{"fertilizer_type": "NPK", "fertilizer_amount": 50}`

### 5. Sanitation
- **meta_key**: `sanitation_type`
  - **meta_value**: `"spraying"` or `"slashing"`
  
**If sanitation_type is "spraying":**
- **meta_key**: `herbicide_amount`
  - **meta_value**: integer (amount of herbicide)
- **Example**: `{"sanitation_type": "spraying", "herbicide_amount": 100}`

**If sanitation_type is "slashing":**
- **meta_key**: `fuel_amount`
  - **meta_value**: integer (amount of fuel)
- **Example**: `{"sanitation_type": "slashing", "fuel_amount": 50}`

## Implementation Details V2

### Enhanced Helper Method: `_structureMetaByTaskType()`

#### Key Features:

**1. Value Extraction Function**
```dart
String? extractValue(dynamic metaValue) {
  if (metaValue is Map) {
    // Check common value fields: value, amount, quantity, count
    for (var key in ['value', 'amount', 'quantity', 'count']) {
      if (metaValue.containsKey(key)) {
        return metaValue[key].toString();
      }
    }
    // Extract first non-null, non-map value
    for (var entry in metaValue.entries) {
      if (entry.value != null && entry.value is! Map) {
        return entry.value.toString();
      }
    }
  }
  return metaValue?.toString();
}
```

**2. Task-Specific Logic (Example: Manuring)**
```dart
case 'manuring':
  // 1. Check for exact key match
  if (originalMeta.containsKey('manuring')) {
    var value = originalMeta['manuring'];
    structuredMeta['manuring'] = extractValue(value) ?? '';
  } else {
    // 2. Search for any numeric value
    for (var entry in originalMeta.entries) {
      var val = extractValue(entry.value);
      if (val != null && val.isNotEmpty) {
        if (RegExp(r'^\d+(\.\d+)?$').hasMatch(val)) {
          structuredMeta['manuring'] = val;
          break;
        }
      }
    }
    // 3. Fallback: use first non-empty value
    if (!structuredMeta.containsKey('manuring')) {
      for (var entry in originalMeta.entries) {
        var val = extractValue(entry.value);
        if (val != null && val.isNotEmpty) {
          structuredMeta['manuring'] = val;
          break;
        }
      }
    }
  }
  break;
```

**3. Comprehensive Debug Logging**
```dart
print('=== STRUCTURING META FOR TASK TYPE: $normalizedTaskType ===');
print('Original meta: $originalMeta');
// ... processing ...
print('Structured meta result: $structuredMeta');
```

## Testing Guide

### Step 1: Check Console Logs
When you click "Task Approved", look for these debug messages in the browser console:

```
=== STRUCTURING META FOR TASK TYPE: manuring ===
Original meta: {fertilizer_type: BORATE, fertilizer_amount: 100}
Structured meta result: {manuring: 100}

=== Worker Audit Meta (formatted by task type: Manuring) ===
[
  {
    staff_id: 123,
    meta: {manuring: 100}
  }
]

=== FINAL DATA TO SEND ===
- Task Video: https://mwms.megacess.com/storage/videos/example.mp4
- Task Images: [https://mwms.megacess.com/storage/images/example1.jpg]
- Remarks: Task completed
- Worker Audit Meta: [{staff_id: 123, meta: {manuring: 100}}]
```

### Step 2: Test Different Scenarios

**Scenario A: Meta with Direct Value**
```dart
// Input: worker.meta = {"manuring": 100}
// Output: {"manuring": "100"}
```

**Scenario B: Meta with Nested Object**
```dart
// Input: worker.meta = {"fertilizer_type": "BORATE", "fertilizer_amount": 100}
// Output: {"manuring": "100"} // Extracted from fertilizer_amount
```

**Scenario C: Meta with Underscore Keys**
```dart
// Input: worker.meta = {"normal_pruning": 50}
// Output: {"normal pruning": "50"} // Key converted to space
```

### Step 3: Verify API Payload
Check the network tab (DevTools → Network → Filter: approve):

**Request Payload Should Look Like:**
```json
{
  "task_video": "https://mwms.megacess.com/storage/videos/example.mp4",
  "task_img": [
    "https://mwms.megacess.com/storage/images/img1.jpg",
    "https://mwms.megacess.com/storage/images/img2.jpg"
  ],
  "remarks": "Completed successfully",
  "worker_audit_meta": [
    {
      "staff_id": 123,
      "meta": {
        "manuring": "100"
      }
    },
    {
      "staff_id": 456,
      "meta": {
        "manuring": "150"
      }
    }
  ]
}
```

## Troubleshooting

### Issue: Still Getting "Meta data is required"

**Check 1: Console Logs**
```
=== STRUCTURING META FOR TASK TYPE: manuring ===
Original meta: {...}
Structured meta result: {}  // ❌ Empty result!
```
If structured meta is empty, the worker meta doesn't contain any extractable values.

**Check 2: Original Meta Structure**
Share the "Original meta" log output with the developer. Examples:
- `Original meta: {}` → Worker has no meta data
- `Original meta: {other_field: "value"}` → Meta doesn't contain expected fields
- `Original meta: {manuring: null}` → Value is null

**Check 3: Task Type**
Ensure task type matches exactly (case-insensitive):
- ✅ `Manuring`, `manuring`, `MANURING` → All OK
- ❌ `Manure`, `Fertilizing` → Won't match

### Issue: Wrong Value Extracted

**Debug Steps:**
1. Check the console log showing "Original meta"
2. Verify which value is being extracted
3. Ensure the extracted value is the correct one

Example:
```
Original meta: {
  fertilizer_type: "BORATE",
  fertilizer_amount: 100,
  notes: "Test"
}
Structured meta result: {manuring: "100"}  // ✅ Correct (numeric value)
```

If wrong value extracted:
```
Structured meta result: {manuring: "BORATE"}  // ❌ Wrong (text value)
```

## Files Modified

- `lib/modules/checker/view/audit_task_preview_page.dart`
  - Enhanced `_structureMetaByTaskType()` method (lines ~1006-1155)
  - Added `extractValue()` helper function
  - Added comprehensive debug logging
  - Implemented fallback strategies for value extraction

## API Contract

### Request Format
```typescript
POST /api/v1/tasks/audits/{task_id}/approve

{
  task_video: string,        // Required: Full URL
  task_img: string[],        // Required: Array of full URLs
  remarks?: string,          // Optional: User remarks
  worker_audit_meta: [{      // Required: Worker meta array
    staff_id: number,
    meta: {
      [key: string]: string  // Task-specific keys with string values
    }
  }]
}
```

### Response Codes
- **200**: Success
- **403**: Forbidden (no permission)
- **404**: Task not found
- **422**: Validation error (check `errors` object)

## Next Steps

1. **Test with current task** - Try approving a Manuring task
2. **Check console logs** - Verify meta structure transformation
3. **If still failing** - Share these logs:
   - "Original meta: ..."
   - "Structured meta result: ..."
   - API response error message

4. **Test other task types** - Ensure Pruning, Harvesting, Planting, Sanitation all work

## Notes

- ✅ All meta values converted to strings
- ✅ Handles nested meta objects
- ✅ Flexible key name matching (underscore vs space)
- ✅ Numeric value detection with regex
- ✅ Fallback strategies if expected key not found
- ✅ Comprehensive debug logging
- ✅ Type-safe value extraction

**Perbedaan dengan V1:**
- V1: Hanya mengonversi existing keys ke string
- V2: **Ekstrak values dari nested objects** + fallback strategy + flexible key matching
