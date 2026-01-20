# DBMS System - Comprehensive Test Cases

## Test Environment Setup
- Navigate to: `/home/keroraed/ITI/BASH/Project`
- Run: `bash dbms.sh`

---

## PART 1: DATABASE OPERATIONS

### Test Case 1.1: Create Valid Database ✓
**Steps:**
1. Select option: `1` (CreateDB)
2. Enter DB name: `test_db`
3. Expected: "DB is Created ......"
4. Verify: Database folder exists in `.DBMS/test_db`

### Test Case 1.2: Create Database - Empty Name ✗
**Steps:**
1. Select option: `1` (CreateDB)
2. Press Enter (empty input)
3. Expected: "Error 100: DB Name Cannot be Empty"

### Test Case 1.3: Create Database - Starts with Number ✗
**Steps:**
1. Select option: `1` (CreateDB)
2. Enter DB name: `123database`
3. Expected: "Error 101: Name of DB Can't Start Numbers"

### Test Case 1.4: Create Database - Special Characters ✗
**Steps:**
1. Select option: `1` (CreateDB)
2. Enter DB name: `test@db#`
3. Expected: "Error 104: Name of Folder Contains Special Character"

### Test Case 1.5: Create Database - Only Underscore ✗
**Steps:**
1. Select option: `1` (CreateDB)
2. Enter DB name: `_`
3. Expected: "Error 102: Name of DB Can't be _"

### Test Case 1.6: Create Database - Already Exists ✗
**Steps:**
1. Select option: `1` (CreateDB)
2. Enter DB name: `test_db` (same as Test 1.1)
3. Expected: "Error 103: DB Name Already Exists"

### Test Case 1.7: Create Database - Long Name ✗
**Steps:**
1. Select option: `1` (CreateDB)
2. Enter DB name: `this_is_a_very_long_database_name_that_exceeds_sixty_four_characters_limit`
3. Expected: "Error 105: DB Name Too Long (max 64 characters)"

### Test Case 1.8: Create Database - Name with Spaces
**Steps:**
1. Select option: `1` (CreateDB)
2. Enter DB name: `my database`
3. Expected: Should convert to `my_database` and create successfully

### Test Case 1.9: List All Databases ✓
**Steps:**
1. Select option: `2` (ListAllDB)
2. Expected: Should show `test_db` and `my_database`

### Test Case 1.10: List Databases - Empty System
**Steps:**
1. Remove all databases first (Test 1.15-1.16)
2. Select option: `2` (ListAllDB)
3. Expected: "Error 107: DBMS Empty No DataBases for Listing"

---

## PART 2: TABLE OPERATIONS (Connect to Database First)

### Setup for Table Tests:
1. Select option: `3` (ConnectDB)
2. Enter DB name: `test_db`
3. You should now see prompt: `test_db>>`

### Test Case 2.1: Create Table with Valid Schema ✓
**Steps:**
1. Select option: `1` (CreateTable)
2. Enter table name: `students`
3. Enter column count: `4`
4. Col 1 Name: `id`, Type: `int`
5. Col 2 Name: `name`, Type: `str`
6. Col 3 Name: `age`, Type: `int`
7. Col 4 Name: `grade`, Type: `str`
8. Expected: "Table is Created with schema......"

### Test Case 2.2: Create Table - Empty Name ✗
**Steps:**
1. Select option: `1` (CreateTable)
2. Press Enter (empty input)
3. Expected: "Error 200: Table Name Cannot be Empty"

### Test Case 2.3: Create Table - Starts with Number ✗
**Steps:**
1. Select option: `1` (CreateTable)
2. Enter table name: `1students`
3. Expected: "Error 201: Name of Table Can't Start Numbers"

### Test Case 2.4: Create Table - Special Characters ✗
**Steps:**
1. Select option: `1` (CreateTable)
2. Enter table name: `students!@#`
3. Expected: "Error 204: Name of Table Contains Special Character"

### Test Case 2.5: Create Table - Already Exists ✗
**Steps:**
1. Select option: `1` (CreateTable)
2. Enter table name: `students` (same as Test 2.1)
3. Expected: "Error 203: Table Already Exists"

### Test Case 2.6: Create Table - Invalid Column Count ✗
**Steps:**
1. Select option: `1` (CreateTable)
2. Enter table name: `invalid_table`
3. Enter column count: `abc` or `0` or `-5`
4. Expected: "Error: Invalid column count"

### Test Case 2.7: Create Table - Invalid Column Type ✗
**Steps:**
1. Select option: `1` (CreateTable)
2. Enter table name: `invalid_table2`
3. Enter column count: `2`
4. Col 1 Name: `id`, Type: `number` (invalid type)
5. Expected: "Error: Invalid type. Use int or str"

### Test Case 2.8: List All Tables ✓
**Steps:**
1. Select option: `2` (ListAllTables)
2. Expected: Should show `students`

### Test Case 2.9: Insert Row - Valid Data ✓
**Steps:**
1. Select option: `3` (InsertIntoTable)
2. Select table: `1` (students)
3. Enter id (int): `101`
4. Enter name (str): `Ahmed Ali`
5. Enter age (int): `20`
6. Enter grade (any): `A`
7. Expected: "✅ Row inserted successfully."

### Test Case 2.10: Insert Row - Duplicate Primary Key ✗
**Steps:**
1. Select option: `3` (InsertIntoTable)
2. Select table: `1` (students)
3. Enter id (int): `101` (same as Test 2.9)
4. Expected: "❌ ID already exists."

### Test Case 2.11: Insert Row - Invalid Type (int field) ✗
**Steps:**
1. Select option: `3` (InsertIntoTable)
2. Select table: `1` (students)
3. Enter id (int): `abc`
4. Expected: "❌ Must be digits."
5. Re-enter valid id: `102`
6. Complete the row with valid data

### Test Case 2.12: Insert Row - Invalid Type (str field) ✗
**Steps:**
1. Select option: `3` (InsertIntoTable)
2. Select table: `1` (students)
3. Enter id (int): `103`
4. Enter name (str): `Ahmed123` (contains numbers)
5. Expected: "❌ Must be letters."
6. Re-enter valid name: `Mohamed Hassan`
7. Complete the row

### Test Case 2.13: Insert Row - Empty Required Field ✗
**Steps:**
1. Select option: `3` (InsertIntoTable)
2. Select table: `1` (students)
3. Enter id (int): Press Enter (empty)
4. Expected: "❌ Required."
5. Re-enter valid id and complete

### Test Case 2.14: Insert Row - Contains Separator Character ✗
**Steps:**
1. Select option: `3` (InsertIntoTable)
2. Select table: `1` (students)
3. Enter id (int): `104`
4. Enter name (str): `Ahmed:Ali` (contains :)
5. Expected: "❌ Error: ':' not allowed."
6. Re-enter without separator

### Test Case 2.15: Insert Multiple Rows ✓
**Steps:**
1. Insert 5 more rows with valid data
   - `105, Sara Mohamed, 22, B`
   - `106, Khaled Ahmed, 21, A`
   - `107, Fatma Hassan, 23, C`
   - `108, Omar Ali, 20, B`

### Test Case 2.16: Select All Rows ✓
**Steps:**
1. Select option: `6` (SelectFromTable)
2. Select table: `1` (students)
3. Choose: `1` (View All Rows)
4. Expected: Should display all rows in formatted table

### Test Case 2.17: Select by ID - Valid ✓
**Steps:**
1. Select option: `6` (SelectFromTable)
2. Select table: `1` (students)
3. Choose: `2` (Search by ID)
4. Enter ID: `101`
5. Expected: Should show header and row with ID 101

### Test Case 2.18: Select by ID - Not Found ✗
**Steps:**
1. Select option: `6` (SelectFromTable)
2. Select table: `1` (students)
3. Choose: `2` (Search by ID)
4. Enter ID: `999`
5. Expected: "❌ No record found with ID: 999"

### Test Case 2.19: Update Row - Valid ✓
**Steps:**
1. Select option: `4` (UpdateTable)
2. Select table: `1` (students)
3. Enter ID to update: `101`
4. Update name: Press Enter (keep current)
5. Update age: `21`
6. Update grade: `A+`
7. Expected: "✅ Row updated successfully."

### Test Case 2.20: Update Row - ID Not Found ✗
**Steps:**
1. Select option: `4` (UpdateTable)
2. Select table: `1` (students)
3. Enter ID to update: `999`
4. Expected: "❌ ID not found."

### Test Case 2.21: Update Row - Change ID to Duplicate ✗
**Steps:**
1. Select option: `4` (UpdateTable)
2. Select table: `1` (students)
3. Enter ID to update: `102`
4. New id: `101` (already exists)
5. Expected: "❌ ID already exists."
6. Enter different valid ID or keep current

### Test Case 2.22: Update Row - Invalid Type ✗
**Steps:**
1. Select option: `4` (UpdateTable)
2. Select table: `1` (students)
3. Enter ID to update: `103`
4. New age: `twenty` (invalid for int)
5. Expected: "❌ Must be digits."
6. Re-enter valid age

### Test Case 2.23: Delete Row - Valid with Confirmation ✓
**Steps:**
1. Select option: `5` (DeleteFromTable)
2. Select table: `1` (students)
3. Enter ID to delete: `108`
4. Confirm: `yes`
5. Expected: "🗑️ Row deleted successfully (ID: 108)"

### Test Case 2.24: Delete Row - Cancel Operation
**Steps:**
1. Select option: `5` (DeleteFromTable)
2. Select table: `1` (students)
3. Enter ID to delete: `107`
4. Confirm: `no`
5. Expected: "Delete operation cancelled"
6. Verify row still exists

### Test Case 2.25: Delete Row - ID Not Found ✗
**Steps:**
1. Select option: `5` (DeleteFromTable)
2. Select table: `1` (students)
3. Enter ID to delete: `999`
4. Expected: "❌ ID not found. Nothing deleted."

### Test Case 2.26: Create Second Table ✓
**Steps:**
1. Select option: `1` (CreateTable)
2. Enter table name: `courses`
3. Enter column count: `3`
4. Col 1 Name: `course_id`, Type: `int`
5. Col 2 Name: `course_name`, Type: `str`
6. Col 3 Name: `credits`, Type: `int`
7. Insert some rows into this table

### Test Case 2.27: List All Tables - Multiple Tables ✓
**Steps:**
1. Select option: `2` (ListAllTables)
2. Expected: Should show both `students` and `courses`

### Test Case 2.28: Remove Table - With Confirmation ✓
**Steps:**
1. Select option: `7` (RemoveTable)
2. Select table: `2` (courses)
3. Confirm: `yes`
4. Expected: "Table is Deleted Successfully ......."

### Test Case 2.29: Remove Table - Cancel Operation
**Steps:**
1. Create another table for this test
2. Select option: `7` (RemoveTable)
3. Select that table
4. Confirm: `no`
5. Expected: "Delete operation cancelled"
6. Verify table still exists

### Test Case 2.30: Exit from Database ✓
**Steps:**
1. Select option: `8` (Exit)
2. Expected: Return to main DBMS menu with prompt `Kero,BeroDB>>`

---

## PART 3: DATABASE REMOVAL

### Test Case 3.1: Remove Database - With Confirmation ✓
**Steps:**
1. From main menu, select option: `4` (RemoveDB)
2. Select database: `my_database`
3. Confirm: `yes`
4. Expected: "DB is Deleted Secussfuly ......."

### Test Case 3.2: Remove Database - Cancel Operation
**Steps:**
1. Select option: `4` (RemoveDB)
2. Select database: `test_db`
3. Confirm: `no`
4. Expected: "Delete operation cancelled"
5. Verify database still exists using ListAllDB

---

## PART 4: EDGE CASES & STRESS TESTS

### Test Case 4.1: Connect to Non-Existent Database ✗
**Steps:**
1. Select option: `3` (ConnectDB)
2. Enter DB name: `nonexistent_db`
3. Expected: "Error 404: Name DB Not Found"

### Test Case 4.2: Connect to Database - Empty Name ✗
**Steps:**
1. Select option: `3` (ConnectDB)
2. Press Enter (empty input)
3. Expected: "Error 100: DB Name Cannot be Empty"

### Test Case 4.3: Large Data Volume Test ✓
**Steps:**
1. Connect to `test_db`
2. Create table `large_test` with 3 columns
3. Insert 20-30 rows
4. View all rows - should display properly
5. Search for specific IDs
6. Update several rows
7. Delete several rows

### Test Case 4.4: Special Characters in Data (not in names) ✓
**Steps:**
1. Create table with `str` type columns
2. Insert data that contains spaces and letters
3. Expected: Should work fine for str type (just not the separator `:`)
4. Note: Special characters like `!@#$%^&*()` will fail str validation (letters only)

### Test Case 4.5: Empty Table Operations
**Steps:**
1. Create new table `empty_test`
2. Try to view (should show "Table is Empty")
3. Try to search (should show no results)
4. Try to update non-existent ID
5. Try to delete non-existent ID

### Test Case 4.6: Invalid Menu Options ✗
**Steps:**
1. At main menu, enter: `99` or `abc`
2. Expected: Error message
3. At table menu, enter: `99` or `abc`
4. Expected: Error message or "Invalid choice"

### Test Case 4.7: Case Sensitivity Test
**Steps:**
1. Create database: `TestDB`
2. Try to create: `testdb` or `TESTDB`
3. Expected: Should detect as duplicate (case-insensitive)

---

## VERIFICATION CHECKLIST

After completing all tests, verify:

- [ ] `.DBMS/` directory contains all expected databases
- [ ] Each database directory contains table files and `.meta` files
- [ ] Table files contain properly formatted data with `:` separator
- [ ] Metadata files contain column definitions
- [ ] No orphaned files (tables without metadata)
- [ ] All error messages display correctly
- [ ] No system crashes or unexpected behavior
- [ ] Data integrity maintained throughout operations

---

## CLEANUP

After testing:
```bash
# Optional: Remove test data
rm -rf .DBMS/test_db
rm -rf .DBMS/my_database
# Or keep for future reference
```

---

## SUMMARY OF EXPECTED RESULTS

**Total Test Cases: 53**
- Database Operations: 10 tests
- Table Operations: 30 tests
- Database Removal: 2 tests
- Edge Cases: 11 tests

**Success Criteria:**
✓ All validation errors caught properly
✓ All success operations complete without errors
✓ Data integrity maintained
✓ No system crashes
✓ Clear user feedback for all actions
