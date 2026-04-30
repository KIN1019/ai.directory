# PostgreSQL Schema Modernization Tool

This tool automates the modernization of PostgreSQL SQL files by replacing `SET search_path` statements with explicit schema prefixes for all database objects.

## Overview

The tool processes SQL files in the `hkpmi_db` directory structure and:

1. **Removes SET search_path statements** - Eliminates `SET search_path TO schema, public` and `RESET search_path` statements
2. **Adds explicit schema prefixes** - Prefixes all table/view/procedure/trigger/index/sequence references with appropriate schema names (`download.` or `hkpmi.`)
3. **Handles schema conflicts** - Resolves naming conflicts between schemas based on search_path priority
4. **Generates comprehensive reports** - Provides detailed analysis of all changes made

## Directory Structure

```
hkpmi_db/
├── download/  # DOWNLOAD schema files
│   ├── function-n-procedure/
│   ├── table/
│   ├── trigger/
│   └── sequence/
└── hkpmi/     # HKPMI schema files
    ├── function-n-procedure/
    ├── table/
    ├── trigger/
    └── sequence/
```

## Features

### Schema Detection

- Automatically detects `hkpmi` and `download` schemas
- Analyzes all database objects (tables, views, procedures, functions, triggers, indexes, sequences)
- Identifies naming conflicts between schemas

### Smart Prefixing

- Adds schema prefixes only where needed
- Respects existing explicit prefixes
- Skips temporary tables and column references
- Uses search_path priority for conflict resolution

### Conflict Resolution

When the same object name exists in multiple schemas:

- Uses the schema specified in `SET search_path` as priority
- Adds comments to SQL files indicating conflicts
- Documents all conflicts in the report

### Comprehensive Reporting

- Summary statistics
- Schema analysis details
- File-by-file processing results
- Conflict documentation
- Error reporting

## Installation

### Prerequisites

- Python 3.7+
- pip package manager

### Install Dependencies

```bash
cd scripts
pip install -r requirements.txt
```

## Usage

### Basic Usage

```powershell
.\Modernize-PostgreSQL-Schema.ps1 -InputDir "C:\path\to\project\v302"
```

### Advanced Usage

```powershell
.\Modernize-PostgreSQL-Schema.ps1 `
    -InputDir "C:\path\to\input\v302" `
    -OutputDir "C:\path\to\output" `
    -ReportFile "custom_report.md"
```

### Preview Mode

```powershell
.\Modernize-PostgreSQL-Schema.ps1 `
    -InputDir "C:\path\to\project\v302" `
    -WhatIf
```

## Parameters

| Parameter    | Required | Description                                          |
| ------------ | -------- | ---------------------------------------------------- |
| `InputDir`   | Yes      | Path containing the `hkpmi_db` directory             |
| `OutputDir`  | No       | Output directory (defaults to InputDir)              |
| `ReportFile` | No       | Report filename (default: `modernization_report.md`) |
| `WhatIf`     | No       | Preview mode without making changes                  |

## Examples

### Before Modernization

```sql
CREATE OR REPLACE PROCEDURE hkpmi.cpi_get_phonetic_chin_name(...)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_ret_code INTEGER;
BEGIN
    SET LOCAL search_path TO hkpmi,public;
    SELECT * FROM ccc_unicode WHERE ccc_head = '123';
    RESET search_path;
END;
$procedure$
```

### After Modernization

```sql
-- SCHEMA CONFLICT: ccc_unicode exists in both hkpmi and hpi schemas
-- Used hkpmi schema based on search_path priority
CREATE OR REPLACE PROCEDURE hkpmi.cpi_get_phonetic_chin_name(...)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_ret_code INTEGER;
BEGIN
    SELECT * FROM hkpmi.ccc_unicode WHERE ccc_head = '123';
END;
$procedure$
```

## Conflict Resolution

When object names conflict between schemas, the tool:

1. **Checks search_path priority** - Uses the first schema mentioned in `SET search_path`
2. **Adds conflict comments** - Documents the conflict and resolution at the top of the file
3. **Applies consistent prefixes** - Uses the same resolution throughout the file

Example conflict comment:

```sql
-- SCHEMA CONFLICT: table_name exists in both hkpmi and hpi schemas
-- Used hkpmi schema based on search_path priority
```

## Output

### Report Structure

- **Summary**: Overall statistics and success metrics
- **Schema Analysis**: Details of objects found in each schema
- **Conflicts**: List of all naming conflicts and resolutions
- **File Details**: Processing results for each individual file

### Modified Files

- Original files are preserved
- Modernized files are written to the output directory
- Maintains the same directory structure as input

## Validation

The tool includes several validation checks:

- ✅ Correctly removes all `SET search_path` statements
- ✅ Adds schema prefixes to all unqualified table references
- ✅ Preserves temporary table references
- ✅ Avoids modifying column name references
- ✅ Handles all SQL statement types (SELECT, INSERT, UPDATE, DELETE, JOIN, CALL)
- ✅ Resolves schema conflicts appropriately

## Troubleshooting

### Common Issues

1. **Python not found**
   - Ensure Python 3.7+ is installed and in PATH
   - Try using `python3` instead of `python`

2. **Dependencies not installed**
   - Run `pip install -r requirements.txt` manually
   - Check for network connectivity issues

3. **Permission errors**
   - Ensure write permissions to output directory
   - Close any files that might be open in editors

4. **SQL parsing errors**
   - Some complex SQL may fall back to regex processing
   - Check the report for specific error details

### Debug Mode

Enable verbose logging for troubleshooting:

```powershell
$env:PYTHONPATH = "scripts"
python scripts/pg_schema_modernizer.py --input-dir "C:\path\to\input" --verbose
```

## Architecture

### Core Components

1. **Schema Analyzer** - Scans directory structure and catalogs all database objects
2. **Conflict Detector** - Identifies naming conflicts between schemas
3. **SQL Parser** - Uses SQLGlot for PostgreSQL SQL parsing and transformation
4. **Prefix Applicator** - Adds schema prefixes based on conflict resolution rules
5. **Report Generator** - Creates comprehensive documentation of all changes

### Dependencies

- **SQLGlot**: Advanced SQL parsing and transformation library
- **dataclasses**: Python data structure support (Python 3.7+)
- **pathlib**: Modern path handling
- **re**: Regular expression processing

## Contributing

When modifying the tool:

1. Test on sample files before full runs
2. Update validation checks for new features
3. Maintain backward compatibility
4. Update documentation for new parameters

## License

This tool is part of the HPI Database Modernization project.
