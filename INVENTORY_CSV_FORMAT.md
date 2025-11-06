# Inventory CSV Import/Export Format

## Overview

This document describes the CSV format used for importing and exporting inventory data. The CSV file combines all entities (products, packages, boxes, contractors) in a single file with clear column headers.

## File Structure

### CSV Format
- **Encoding**: UTF-8
- **Delimiter**: Comma (`,`)
- **Quote Character**: Double quote (`"`)
- **Header Row**: Required (first row)
- **Line Ending**: Any (`\r\n`, `\n`, or `\r`)

### Column Headers

```csv
Type,Serial Number,Name,Description,Category,Quantity,Package Name,Box Name,Contractor Name,Location,Status,Created Date,Shipped Date,Delivered Date
```

## Column Descriptions

| Column | Required | Description | Values/Format |
|--------|----------|-------------|---------------|
| **Type** | Yes | Entity type | `Product`, `Package`, `Box`, `Contractor` |
| **Serial Number** | Product only | Unique product identifier | Any string |
| **Name** | Yes | Entity name | Any string |
| **Description** | No | Entity description | Any string |
| **Category** | Product only | Product category name | Category name from app |
| **Quantity** | Product only | Product quantity | Number (integer) |
| **Package Name** | Product only | Package this product belongs to | Package name (must exist) |
| **Box Name** | Product only | Box this product is stored in | Box name (must exist) |
| **Contractor Name** | Package only | Contractor for this package | Contractor name (must exist) |
| **Location** | Box only | Physical location of box | Any string |
| **Status** | Package only | Package status | `Pending`, `In Transit`, `Delivered` |
| **Created Date** | No | Creation timestamp | ISO 8601 format |
| **Shipped Date** | Package only | When package was shipped | ISO 8601 format |
| **Delivered Date** | Package only | When package was delivered | ISO 8601 format |

## Examples

### Product Only
```csv
Type,Serial Number,Name,Description,Category,Quantity,Package Name,Box Name,Contractor Name,Location,Status,Created Date,Shipped Date,Delivered Date
Product,SN001,Zebra Scanner TC21,Handheld barcode scanner,Scanner,1,,,,,,,
Product,SN002,Zebra Printer ZD421,Label printer 203dpi,Printer,1,,,,,,,
```

### Product with Package Assignment
```csv
Type,Serial Number,Name,Description,Category,Quantity,Package Name,Box Name,Contractor Name,Location,Status,Created Date,Shipped Date,Delivered Date
Product,SN003,USB Cable,Charging cable for scanner,Cable,5,Shipment to Warehouse,,,,,,,
```

### Product with Box Assignment
```csv
Type,Serial Number,Name,Description,Category,Quantity,Package Name,Box Name,Contractor Name,Location,Status,Created Date,Shipped Date,Delivered Date
Product,SN004,Label Roll,Thermal labels 4x6,Labels,10,,Storage Box A,,,,,
```

### Package
```csv
Type,Serial Number,Name,Description,Category,Quantity,Package Name,Box Name,Contractor Name,Location,Status,Created Date,Shipped Date,Delivered Date
Package,,,Shipment to Warehouse,,,,,Acme Corp,,Pending,,,
```

### Box
```csv
Type,Serial Number,Name,Description,Category,Quantity,Package Name,Box Name,Contractor Name,Location,Status,Created Date,Shipped Date,Delivered Date
Box,,,Storage Box A,Main warehouse storage box,,,,,,Shelf A-5,,,
```

### Contractor
```csv
Type,Serial Number,Name,Description,Category,Quantity,Package Name,Box Name,Contractor Name,Location,Status,Created Date,Shipped Date,Delivered Date
Contractor,,,Acme Corp,Shipping contractor,,,,,,,,,
```

## Complete Example

```csv
Type,Serial Number,Name,Description,Category,Quantity,Package Name,Box Name,Contractor Name,Location,Status,Created Date,Shipped Date,Delivered Date
Contractor,,,Acme Corp,Shipping contractor,,,,,,,,,
Contractor,,,FastShip Ltd,Express delivery,,,,,,,,,
Package,,,Shipment to Warehouse,Equipment for warehouse,,,,Acme Corp,,Pending,,,
Package,,,Office Supplies,Monthly office supplies,,,,FastShip Ltd,,In Transit,,,
Box,,,Storage Box A,Main warehouse storage,,,,,,Shelf A-5,,,
Box,,,Storage Box B,Backup equipment storage,,,,,,Shelf B-3,,,
Product,SN001,Zebra Scanner TC21,Handheld barcode scanner,Scanner,1,Shipment to Warehouse,,,,,,,
Product,SN002,Zebra Printer ZD421,Label printer 203dpi,Printer,1,Shipment to Warehouse,,,,,,,
Product,SN003,USB Cable,Charging cable,Cable,5,Office Supplies,,,,,,,
Product,SN004,Label Roll,Thermal labels 4x6,Labels,10,,Storage Box A,,,,,
Product,SN005,Spare Battery,Scanner battery pack,Battery,2,,Storage Box B,,,,,
```

## Import Rules

1. **Order Matters**: Import contractors, packages, and boxes BEFORE products that reference them
2. **Name Matching**: Package Name, Box Name, and Contractor Name must match exactly (case-sensitive)
3. **Serial Number**: Must be unique per product (used for update/insert logic)
4. **Required Fields**: Type and Name are always required
5. **Empty Cells**: Leave cells empty if not applicable (don't use "N/A" or "-")
6. **Quotes**: Use double quotes if values contain commas: `"Description, with comma"`
7. **Escaping**: Double quotes in values must be escaped: `"He said ""Hello"""`

## Import Behavior

- **Products with existing Serial Number**: UPDATE existing product
- **Products with new Serial Number**: INSERT new product
- **Packages/Boxes/Contractors with existing Name**: UPDATE existing entity
- **Packages/Boxes/Contractors with new Name**: INSERT new entity
- **Package Name**: If product has Package Name, it will be added to that package
- **Box Name**: If product has Box Name, it will be added to that box
- **Missing References**: If Package Name or Box Name doesn't exist, product is imported without that relationship

## Export Behavior

- Exports all entities to a single CSV file
- Products show their assigned Package Name and Box Name
- Packages show their Contractor Name
- All relationships are preserved in readable format

## Template File

A template CSV file can be downloaded from the app:
- Go to: **Export / Import** screen
- Click: **Download CSV Template**
- Location: `Documents/inventory/exports/template.csv`

## Best Practices

1. **Start with Contractors**: Import contractors first if packages need them
2. **Then Packages/Boxes**: Import containers before products
3. **Finally Products**: Import products with references to existing containers
4. **Use Names**: Always use human-readable names for relationships
5. **Test Small**: Start with a small CSV to test the format
6. **Backup First**: Always export existing data before bulk import

## Common Mistakes

❌ **Wrong**: Using ID numbers instead of names
```csv
Product,SN001,Scanner,,Scanner,1,123,456,,,,,
```

✅ **Correct**: Using actual names
```csv
Product,SN001,Scanner,,Scanner,1,Shipment A,Box 1,,,,,
```

❌ **Wrong**: Missing required Type column
```csv
SN001,Scanner,Description,Scanner,1
```

✅ **Correct**: Type column present
```csv
Type,Serial Number,Name,Description,Category,Quantity,Package Name,Box Name,Contractor Name,Location,Status,Created Date,Shipped Date,Delivered Date
Product,SN001,Scanner,Description,Scanner,1,,,,,,,
```

## Troubleshooting

**Problem**: "Import failed - no data imported"
- **Solution**: Check that Type column is present and filled for all rows

**Problem**: "Package 'ABC' not found"
- **Solution**: Import the package row BEFORE products that reference it

**Problem**: "Duplicate serial number"
- **Solution**: Each product must have a unique serial number

**Problem**: "Category 'XYZ' not found"
- **Solution**: Use existing category names from the app (Scanner, Printer, etc.)
