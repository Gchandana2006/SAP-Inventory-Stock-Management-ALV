
# Inventory / Stock Management System using SAP ABAP

## Project Overview

The Inventory / Stock Management System is an SAP ABAP project developed
to monitor material stock across different plants and storage locations.

The project uses custom SAP database tables and an ALV Grid report to
display inventory information in an interactive format.

## Technologies Used

- SAP ABAP
- SAP GUI
- ALV Grid
- Open SQL
- Internal Tables
- Custom Database Tables
- Table Maintenance Generator

## SAP Objects

### Custom Tables

- ZINV_MATERIAL
- ZINV_STOCK

### ABAP Program

- ZINVENTORY_ALV

## Features

- Material-wise inventory display
- Plant-wise filtering
- Storage-location filtering
- Material selection
- Stock quantity display
- Minimum stock comparison
- Stock value calculation
- Stock status determination
- ALV sorting
- ALV filtering
- ALV totals
- ALV layout management
- Double-click functionality

## Database Design

### ZINV_MATERIAL

Stores basic material information such as:

- Material ID
- Material Name
- Material Type
- Unit
- Price

### ZINV_STOCK

Stores inventory information such as:

- Material ID
- Plant
- Storage Location
- Stock Quantity
- Minimum Stock
- Stock Date

## Business Logic

Stock Value:

Stock Quantity × Unit Price

Stock Status:

- Stock Quantity = 0 → Out of Stock
- Stock Quantity < Minimum Stock → Low Stock
- Otherwise → Available

## Program Flow

Selection Screen
↓
Database Selection
↓
INNER JOIN
↓
Internal Table
↓
Stock Value Calculation
↓
Stock Status Calculation
↓
ALV Grid Display

## SAP Transactions Used

- SE80 – Package
- SE11 – Database Tables
- SM30 – Table Maintenance
- SE16N – Table Data
- SE38 – ABAP Program
- ST22 – Runtime Error Analysis

## Author

Chandana
