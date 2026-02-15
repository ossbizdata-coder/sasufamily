# Auto-Value Calculation Feature

## Overview

This feature automatically calculates and displays the current values of assets and liabilities based on time, eliminating the need for manual updates.

## How It Works

### Assets with Auto-Growth

When you enable **Auto-Growth** for an asset:

1. **Purchase Value**: Enter the original value when you bought/started the asset
2. **Purchase Date**: Select the date of purchase (required for auto-growth)
3. **Yearly Growth Rate**: Enter the annual appreciation rate (e.g., 11% for EPF)
4. The app automatically calculates the current value using **compound interest**

**Formula Used:**
```
Current Value = Purchase Value × (1 + rate/365)^(days elapsed)
```

**Default Growth Rates by Asset Type:**
| Asset Type | Default Rate |
|------------|--------------|
| EPF / Retirement Fund | 11% |
| Shares | 12% |
| Land | 8% |
| Fixed Deposit | 7% |
| Gold | 6% |
| House | 5% |
| Savings / Bank Deposit | 3% |
| Vehicle | -15% (depreciation) |

### Liabilities with Auto-Calculate

When you enable **Auto-Calculate** for a liability:

1. **Original Amount**: Enter the total loan amount
2. **Monthly Payment**: Enter your fixed monthly payment (required)
3. **Interest Rate**: Enter the annual interest rate (optional, but improves accuracy)
4. **Start Date**: Select when the loan started (required)
5. The app automatically calculates:
   - Current remaining balance
   - Total paid so far
   - Total interest paid
   - Time remaining until paid off

## Features

### Asset Screen
- Shows calculated current value (auto-updates daily)
- Displays growth rate badge (+X%/yr)
- Shows total gain since purchase
- Projects future values

### Liability Screen
- Shows calculated remaining balance
- Displays "Auto" badge for auto-calculated liabilities
- Shows time remaining until paid off
- Tracks total interest paid

## Example

### EPF with Auto-Growth

**Setup:**
- Asset Name: My EPF
- Type: EPF
- Purchase Value: Rs. 500,000
- Purchase Date: January 1, 2020
- Growth Rate: 11%
- Auto-Growth: ✓ Enabled

**Result (as of February 2026):**
- Current Value: Rs. 960,517 (automatically calculated)
- Total Gain: Rs. 460,517 (+92.1%)

### Home Loan with Auto-Calculate

**Setup:**
- Liability Name: Home Loan
- Type: Home Loan
- Original Amount: Rs. 5,000,000
- Monthly Payment: Rs. 55,000
- Interest Rate: 8.5%
- Start Date: March 1, 2022
- Auto-Calculate: ✓ Enabled

**Result (as of February 2026):**
- Remaining Amount: Rs. 3,245,000 (automatically calculated)
- Total Paid: Rs. 2,530,000
- Interest Paid: Rs. 775,000
- Progress: 35% paid
- Time Remaining: 6 yr 2 mo

## Database Migration

Run the following SQL to add the new columns:

```sql
-- Add to assets table
ALTER TABLE assets ADD COLUMN purchase_date DATE;
ALTER TABLE assets ADD COLUMN auto_growth BOOLEAN DEFAULT FALSE NOT NULL;

-- Add to liabilities table
ALTER TABLE liabilities ADD COLUMN auto_calculate BOOLEAN DEFAULT FALSE NOT NULL;
```

Or simply restart the backend - Hibernate will auto-create the columns.

## Notes

1. **Values update in real-time**: Every time you open the app, values are calculated based on the current date
2. **No backend processing needed**: All calculations happen on the mobile app
3. **Original values preserved**: The database stores the original/purchase values; calculated values are derived
4. **Backward compatible**: Existing assets/liabilities without auto-growth/auto-calculate continue to work as before

