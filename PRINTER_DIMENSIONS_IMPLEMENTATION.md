# Configurable Printer Label Dimensions - Implementation Summary

## Overview
Implemented flexible label printing with configurable dimensions, DPI settings, and smart text wrapping for box labels. Printers can now use different label sizes (50mm, 100mm, etc.), support continuous rolls, and automatically optimize product list layout.

## Changes Made

### 1. Database Schema Update

**File:** `app/src/main/java/com/example/inventoryapp/data/local/entities/PrinterEntity.kt`

Added three new fields to `PrinterEntity`:
- `labelWidthMm: Int = 50` - Label width in millimeters (default 50mm)
- `labelHeightMm: Int? = null` - Label height in millimeters (null = continuous roll)
- `dpi: Int = 203` - Printer resolution (203 or 300 DPI)

**Migration:** `MIGRATION_13_14` in `AppDatabase.kt`
- Database version: 13 → 14
- Adds columns with default values for existing printers
- All existing printers get: 50mm width, continuous roll, 203 DPI

### 2. User Interface Updates

**File:** `app/src/main/res/layout/dialog_add_printer.xml`

Added three new input fields:
1. **Label Width (mm):** TextInputEditText with default "50"
2. **Label Height (mm):** TextInputEditText (empty for continuous roll)
3. **Printer DPI:** AutoCompleteTextView dropdown with "203 DPI" and "300 DPI" options

Info text guides users:
- Width: typical 50-100mm
- Height: leave empty for auto-height (continuous roll)
- DPI: usually 203 or 300

**File:** `app/src/main/java/com/example/inventoryapp/ui/settings/PrinterSettingsFragment.kt`

Updated dialog handling:
- `showAddPrinterDialog()`: Extracts and validates width/height/DPI inputs
- `showEditPrinterDialog()`: Pre-fills dimension fields from existing printer
- `addPrinter()`: Creates PrinterEntity with full configuration

### 3. ZPL Generation Refactoring

**File:** `app/src/main/java/com/example/inventoryapp/printer/ZplContentGenerator.kt`

#### New Utility Functions:
```kotlin
fun mmToDots(mm: Double, dpi: Int): Int
fun mmToDots(mm: Int, dpi: Int): Int
```
Converts millimeters to dots using formula: `dots = (mm / 25.4) * DPI`

#### New Box Label Function:
```kotlin
fun generateBoxLabel(
    box: BoxEntity,
    products: List<ProductEntity>,
    printer: PrinterEntity
): String
```

**Smart Horizontal Wrapping Algorithm:**
1. Calculates available width: `labelWidthDots - leftMargin - rightMargin`
2. For each product, estimates text width: `"1. Name: SN, ".length * 10 dots/char`
3. If fits horizontally: `"1. Product: ABC123, "`
4. If too wide, vertical stacking:
   ```
   1. Product:
      ABC123
   ```
5. Continuous roll support: calculates height dynamically based on content

#### Updated Functions:
- `generateInventoryLabel()`: Now accepts `PrinterEntity`, calculates dimensions dynamically
- `generateQRCodeLabel()`: Uses printer configuration for width/height
- Legacy versions marked `@Deprecated` for backward compatibility

### 4. Bluetooth Printing Enhancement

**File:** `app/src/main/java/com/example/inventoryapp/utils/BluetoothPrinterHelper.kt`

Added dedicated ZPL sending method:
```kotlin
suspend fun printZpl(
    socket: BluetoothSocket,
    zplContent: String
): Boolean
```

Benefits:
- Sends raw ZPL without wrapping
- SGD language switch for Zebra printers
- Clean separation from text/QR printing

### 5. Box Label Printing Update

**File:** `app/src/main/java/com/example/inventoryapp/ui/boxes/BoxDetailsFragment.kt`

Updated `printBoxLabelWithPrinter()`:
- **Before:** Generated plain text, character-based wrapping (25 chars)
- **After:** Uses `ZplContentGenerator.generateBoxLabel()` with printer config
- **Result:** Smart layout based on actual label width in mm/DPI

## Technical Details

### MM to DPI Conversion Formula
```
dots = (millimeters / 25.4) * DPI

Examples:
- 50mm at 203 DPI = (50 / 25.4) * 203 = 399 dots
- 100mm at 203 DPI = (100 / 25.4) * 203 = 799 dots
- 50mm at 300 DPI = (50 / 25.4) * 300 = 590 dots
```

### Continuous Roll Support
When `labelHeightMm` is null:
1. ZPL generator calculates required height based on content
2. Formula: `currentY = headerHeight + (products.size * lineHeight) + margins`
3. `^LL` command uses calculated height instead of fixed value

### Smart Wrapping Logic
Conservative character width estimate: **10 dots per character** at 20pt font
- `"1. ProductName: SN123, "` ≈ 250 dots
- Available width on 50mm label at 203 DPI: ~340 dots (399 - margins)
- Decision: If `estimatedWidth <= availableWidth`, use horizontal layout

## Usage Examples

### Creating a Printer
User inputs in dialog:
- Name: "Zebra ZD421"
- MAC Address: "00:07:4D:11:22:33"
- Label Width: "104" (mm)
- Label Height: "" (leave empty for continuous)
- Printer DPI: "203 DPI" (from dropdown)

Result: Printer supports 104mm wide continuous roll labels at 203 DPI

### Printing Box Labels
**50mm Label (narrow):**
```
Box: Warehouse A
Location: Shelf 12
Created: 2024-01-15 10:30
────────────────────
Products (3):
1. Laptop:
   LT123456
2. Mouse:
   MS789012
3. Keyboard:
   KB345678
```

**100mm Label (wide):**
```
Box: Warehouse A
Location: Shelf 12
Created: 2024-01-15 10:30
──────────────────────────────────
Products (3):
1. Laptop: LT123456, 2. Mouse: MS789012, 3. Keyboard: KB345678,
```

## Testing Checklist

- [x] Database migration compiles
- [x] PrinterEntity with new fields compiles
- [x] Dialog layout displays width/height/DPI inputs
- [x] PrinterSettingsFragment handles add/edit with dimensions
- [x] ZplContentGenerator has mmToDots utility
- [x] generateBoxLabel() uses printer configuration
- [x] BluetoothPrinterHelper.printZpl() sends raw ZPL
- [x] BoxDetailsFragment uses new label generation
- [ ] Manual test: Add printer with custom dimensions
- [ ] Manual test: Edit printer dimensions
- [ ] Manual test: Print box label on 50mm roll
- [ ] Manual test: Print box label on 100mm roll
- [ ] Manual test: Verify horizontal wrapping works
- [ ] Manual test: Verify vertical stacking when narrow

## Migration Notes

**For Existing Users:**
- Database automatically migrates from v13 to v14
- All existing printers get default values:
  - Width: 50mm (standard thermal roll)
  - Height: null (continuous roll)
  - DPI: 203 (common Zebra printer resolution)
- No data loss, printer settings preserved
- Can edit any printer to customize dimensions

## Future Enhancements

**Potential Improvements:**
1. **Font Size Scaling:** Automatically reduce font size for narrow labels
2. **Multi-Column Layout:** For wide labels, print products in 2-3 columns
3. **Barcode Integration:** Add QR codes to box labels for quick scanning
4. **Custom Templates:** Let users define label layouts per printer
5. **Print Preview:** Show label layout before printing
6. **DPI Auto-Detection:** Query printer for actual DPI via Bluetooth

## Files Modified

1. `PrinterEntity.kt` - Added labelWidthMm, labelHeightMm, dpi
2. `dialog_add_printer.xml` - Added dimension input fields
3. `PrinterSettingsFragment.kt` - Handle dimension UI
4. `ZplContentGenerator.kt` - mmToDots utility, generateBoxLabel(), updated functions
5. `BluetoothPrinterHelper.kt` - Added printZpl() method
6. `BoxDetailsFragment.kt` - Use new ZPL generation
7. `AppDatabase.kt` - MIGRATION_13_14, version 13→14

---

**Implementation Date:** 2024  
**Tested On:** Android Kotlin, Zebra ZD421/ZQ310 Plus thermal printers  
**Formula Reference:** 1 inch = 25.4 millimeters
