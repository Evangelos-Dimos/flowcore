# D04: Configuration and Environment Setup Pack

This directory contains the configuration files that control the behavior of the FlowCore Warehouse Simulation System.

## 📁 Files

| File | Purpose |
| :--- | :--- |
| `warehouse.conf` | Business rules and operational parameters (e.g., permitted product types, location mappings, capacity limits). |
| `db.conf` | Database connection credentials for the Oracle backend. |

## ⚙️ Configuration Parameters (warehouse.conf)

| Parameter | Description | Example |
| :--- | :--- | :--- |
| `VALID_TYPES` | List of allowed product types (space-separated). | `laptop tablet smartphone` |
| `MAX_ITEMS_PER_LOCATION` | Maximum capacity per physical rack. We suppose that every rack has the same product capacity for convenience. | `10` |
| `ALLOWED_LOCATIONS_<type>` | Maps a product type to a specific rack automatically. | `ALLOWED_LOCATIONS_*` | Allowed product locations to be stored.
|`DEFAULT_ORDER_STATUS="PENDING"`| Default order status |`"Pending"`|.
|`COMPLETED_STATUS="COMPLETED"`| Order status |`"Completed"`|.
|`FAILED_STATUS="FAILED"`| Order status |`"Failed"`|.
|`ID_PREFIX`| Products id prefix. Every product id will start with the letter defined in this variable. |`"P"`|
|`LOG_FILE`| All system logs end up here. |`"../logs/system.log"`|
|`LOG_LEVEL`| Determines how much and what kind of information will be recorded in the `"system.log"` file. |`INFO`|
|`SCRIPT_DIR`| Linux bash scripts path. |`"../scripts"`|

> **Note:** Any change to `warehouse.conf` requires running the `sync_config_to_db.sh` script to apply the new rules to the database (commissioning process) before the execution of `warehouse.conf`.

## 🔐 Database Connection (db.conf)

This file stores the credentials used by the Bash scripts to connect to the Oracle database. It is sourced by `docker.sh`.

| Parameter | Description |
| :--- | :--- |
| `DB_CONTAINER` | Name of the Docker container (e.g., `oracle23ai`). |
| `DB_USER` | Database username (e.g., `system`). |
| `DB_PASSWORD` | User password. |
| `DB_SERVICE` | Oracle service name (e.g., `FREEPDB1`). |

> **Important:** `db.conf` is excluded from version control (via `.gitignore`) to keep credentials secure.

## 🚀 Usage

1.  **Edit Business Rules:** Modify `warehouse.conf` as needed.
2.  **Validate Configuration:** Run the C++ validation tool (`../D09_CPP_Component/validate_config`).
3.  **Apply Changes:** Execute `../D05_Bash_Scripts/sync_config_to_db.sh` to synchronize the new configuration with the database.
4.  **Run Operations:** Use the operational scripts (`receive_product.sh`, `dispatch_order.sh` etc) which will respect the current configuration.

> ##### Note for the team:
> *   The `db.conf` file is designed to be excluded from version control (e.g., via `.gitignore`) to protect sensitive credentials.
> *   The `warehouse.conf` file should be committed to the repository as it contains the business logic that is part of the project's documentation and commissioning process.
