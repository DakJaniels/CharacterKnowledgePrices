# Changelog

## [1.0.2] - 2026-11-24

- The column price is the average of every selected source that has a price for that recipe or plan. Master Merchant and Arkadius Trade Tools use their sale average. Tamriel Trade Centre uses its listing average.
- Price source settings choose Master Merchant, Arkadius Trade Tools, and Tamriel Trade Centre. All three start on. A source that is off, not installed, or has no price for the item is left out. Changing a source updates the column without a reload.

## [1.0.1] - 2026-11-24

- Added LICENSE file to addon folder.

## [1.0.0] - 2026-11-24

- Gold prices for recipes and furnishing plans appear in Character Knowledge's auxiliary column. The price is the recipe or plan, from LibPrice.
- Amounts use the client's abbreviated number format.
- The column stays off until Show price column is enabled. Turning it on applies after a UI reload.
