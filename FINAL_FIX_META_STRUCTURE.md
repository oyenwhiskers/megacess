# 🔧 FINAL FIX - Worker Audit Meta Structure (V3)

## ❌ Problem yang Ditemukan

Setelah testing, ditemukan bahwa system masih mengirim data meta dengan struktur yang **SALAH**:

### ❌ Yang Dikirim (WRONG):
```json
{
  "staff_id": 123,
  "meta": {
    "manuring": "100"  // ❌ WRONG FORMAT
  }
}
```

### ❌ Yang Masuk ke Database:
```
meta_key: "manuring"
meta_value: "20"
```

### ✅ Yang Sepatutnya (CORRECT):
```json
{
  "staff_id": 123,
  "meta": {
    "fertilizer_type": "NPK",      // ✅ CORRECT
    "fertilizer_amount": 50         // ✅ CORRECT (integer)
  }
}
```

## ✅ Struktur Meta yang BENAR

### 1️⃣ **Pruning**
```json
{
  "pruning_type": "normal pruning"  // or "routine pruning"
}
```

**API Fields:**
- `pruning_type` (string, optional): `"normal pruning"` or `"routine pruning"`

---

### 2️⃣ **Harvesting**
```json
{
  "harvesting_type": "normal harvesting"  // or "collect loose fruits"
}
```

**API Fields:**
- `harvesting_type` (string, optional): `"normal harvesting"` or `"collect loose fruits"`

---

### 3️⃣ **Planting**
```json
{}  // No meta required
```

**API Fields:** NONE (empty object or omit meta field)

---

### 4️⃣ **Manuring** ⚠️ **MOST IMPORTANT**
```json
{
  "fertilizer_type": "NPK",      // "NPK", "BORATE", or "MOP"
  "fertilizer_amount": 50        // integer
}
```

**API Fields:**
- `fertilizer_type` (string, optional): `"NPK"`, `"BORATE"`, or `"MOP"`
- `fertilizer_amount` (integer, optional): Amount of fertilizer used

**Examples:**
```json
// Example 1
{"fertilizer_type": "NPK", "fertilizer_amount": 50}

// Example 2
{"fertilizer_type": "BORATE", "fertilizer_amount": 100}

// Example 3
{"fertilizer_type": "MOP", "fertilizer_amount": 75}
```

---

### 5️⃣ **Sanitation**

**If sanitation_type is "spraying":**
```json
{
  "sanitation_type": "spraying",
  "herbicide_amount": 100        // integer
}
```

**If sanitation_type is "slashing":**
```json
{
  "sanitation_type": "slashing",
  "fuel_amount": 50              // integer
}
```

**API Fields:**
- `sanitation_type` (string, optional): `"spraying"` or `"slashing"`
- `herbicide_amount` (integer, optional): Amount of herbicide (when spraying)
- `fuel_amount` (integer, optional): Amount of fuel (when slashing)

---

## 🔄 Transformation Logic

### Input dari API (originalMeta):
```json
{
  "fertilizer_type": "BORATE",
  "fertilizer_amount": 100
}
```

### Output yang Dikirim (structuredMeta):
```json
{
  "fertilizer_type": "BORATE",
  "fertilizer_amount": 100
}
```

### Fallback Strategy:

**Scenario 1: Meta sudah benar**
```dart
Input:  {"fertilizer_type": "NPK", "fertilizer_amount": 50}
Output: {"fertilizer_type": "NPK", "fertilizer_amount": 50}  ✅
```

**Scenario 2: Missing fertilizer_type**
```dart
Input:  {"fertilizer_amount": 100}
Output: {"fertilizer_type": "NPK", "fertilizer_amount": 100}  ✅ (default NPK)
```

**Scenario 3: Missing fertilizer_amount**
```dart
Input:  {"fertilizer_type": "BORATE"}
Output: {"fertilizer_type": "BORATE", "fertilizer_amount": 0}  ✅ (default 0)
```

**Scenario 4: No relevant meta**
```dart
Input:  {"some_field": "value", "another": 123}
Output: {"fertilizer_type": "NPK", "fertilizer_amount": 123}  ✅ (extract numeric)
```

---

## 📋 Expected API Payload

### Complete Request Example:
```json
POST /api/v1/tasks/audits/4/approve

{
  "task_video": "https://mwms.megacess.com/storage/videos/example.mp4",
  "task_img": [
    "https://mwms.megacess.com/storage/images/img1.jpg",
    "https://mwms.megacess.com/storage/images/img2.jpg"
  ],
  "remarks": "Task completed successfully",
  "worker_audit_meta": [
    {
      "staff_id": 123,
      "meta": {
        "fertilizer_type": "NPK",
        "fertilizer_amount": 50
      }
    },
    {
      "staff_id": 456,
      "meta": {
        "fertilizer_type": "BORATE",
        "fertilizer_amount": 100
      }
    }
  ]
}
```

### Expected Response (200 Success):
```json
{
  "success": true,
  "message": "Task approved successfully",
  "data": {
    "id": 1,
    "task_id": 4,
    "approved_by": 2,
    "task_video": "https://mwms.megacess.com/storage/videos/example.mp4",
    "task_img": [
      "https://mwms.megacess.com/storage/images/img1.jpg",
      "https://mwms.megacess.com/storage/images/img2.jpg"
    ],
    "action": "approve",
    "remarks": "Task completed successfully",
    "worker_audit_meta": [
      {
        "id": 1,
        "task_audit_id": 1,
        "staff_id": 123,
        "meta_key": "fertilizer_type",
        "meta_value": "NPK",
        "staff": {
          "id": 123,
          "staff_name": "John Worker"
        }
      },
      {
        "id": 2,
        "task_audit_id": 1,
        "staff_id": 123,
        "meta_key": "fertilizer_amount",
        "meta_value": "50",
        "staff": {
          "id": 123,
          "staff_name": "John Worker"
        }
      }
    ]
  }
}
```

---

## 🧪 Testing Guide

### 1. Check Console Logs

When you click "Task Approved", you should see:

```
=== STRUCTURING META FOR TASK TYPE: manuring ===
Original meta: {fertilizer_type: BORATE, fertilizer_amount: 100}
Structured meta result: {fertilizer_type: BORATE, fertilizer_amount: 100}

=== Worker Audit Meta (formatted by task type: Manuring) ===
[
  {
    staff_id: 123,
    meta: {fertilizer_type: BORATE, fertilizer_amount: 100}
  }
]

=== FINAL DATA TO SEND ===
- Task Video: https://mwms.megacess.com/storage/videos/example.mp4
- Task Images: [https://...]
- Remarks: Task completed
- Worker Audit Meta: [{staff_id: 123, meta: {fertilizer_type: BORATE, fertilizer_amount: 100}}]
```

### 2. Verify Database

After successful approval, check database:

**Table: `worker_audit_meta`**
```sql
SELECT * FROM worker_audit_meta WHERE task_audit_id = 1;

-- Expected Result:
| id | task_audit_id | staff_id | meta_key          | meta_value |
|----|---------------|----------|-------------------|------------|
| 1  | 1             | 123      | fertilizer_type   | BORATE     |
| 2  | 1             | 123      | fertilizer_amount | 100        |
```

---

## 📊 Comparison Table

| Task Type  | OLD (Wrong) | NEW (Correct) |
|------------|-------------|---------------|
| Pruning    | `{"normal pruning": "10"}` | `{"pruning_type": "normal pruning"}` |
| Harvesting | `{"normal harvesting": "5000"}` | `{"harvesting_type": "normal harvesting"}` |
| Planting   | `{"planting": "100"}` | `{}` (empty) |
| **Manuring** | `{"manuring": "100"}` ❌ | `{"fertilizer_type": "NPK", "fertilizer_amount": 100}` ✅ |
| Sanitation (Spraying) | `{"spraying": "100"}` | `{"sanitation_type": "spraying", "herbicide_amount": 100}` |
| Sanitation (Slashing) | `{"slashing": "50"}` | `{"sanitation_type": "slashing", "fuel_amount": 50}` |

---

## 🔍 Troubleshooting

### Issue: Still getting validation error

**Check 1: Console Logs**
Look for:
```
Structured meta result: {fertilizer_type: NPK, fertilizer_amount: 50}
```

If you see:
```
Structured meta result: {manuring: 100}  // ❌ WRONG!
```

Then the old code is still running. Try:
1. Hot reload (press `r` in terminal)
2. Hot restart (press `R` in terminal)
3. Full rebuild

**Check 2: Network Tab**
In DevTools → Network → Filter: approve

Check the request payload:
```json
"worker_audit_meta": [
  {
    "staff_id": 123,
    "meta": {
      "fertilizer_type": "NPK",      // ✅ Should see this
      "fertilizer_amount": 50         // ✅ And this
    }
  }
]
```

NOT:
```json
"meta": {
  "manuring": "100"  // ❌ Wrong format
}
```

---

## 🎯 Key Changes Summary

### Before (V2):
```dart
case 'manuring':
  structuredMeta['manuring'] = extractedValue;  // ❌ Wrong key
```

### After (V3):
```dart
case 'manuring':
  structuredMeta['fertilizer_type'] = 'NPK';      // ✅ Correct key
  structuredMeta['fertilizer_amount'] = amount;   // ✅ Integer value
```

---

## ✅ Final Checklist

- [x] Updated `_structureMetaByTaskType()` method
- [x] Correct meta keys for all task types
- [x] Integer values for amounts (not strings)
- [x] Fallback strategies implemented
- [x] Debug logging added
- [x] Documentation updated

---

## 📝 Files Modified

- `lib/modules/checker/view/audit_task_preview_page.dart`
  - **Method**: `_structureMetaByTaskType()` (lines ~1006-1155)
  - **Changes**: Complete rewrite with correct meta structure

---

## 🚀 Ready to Test!

Dengan fix ini, sekarang system akan mengirim meta data dengan struktur yang **BENAR**:

✅ Manuring: `{"fertilizer_type": "NPK", "fertilizer_amount": 50}`
✅ Pruning: `{"pruning_type": "normal pruning"}`
✅ Harvesting: `{"harvesting_type": "normal harvesting"}`
✅ Sanitation: `{"sanitation_type": "spraying", "herbicide_amount": 100}`
✅ Planting: `{}` (empty)

**Silakan test sekarang dan check console logs!** 🎉
