@testable import SQLiteDebugerTests
import SQLiteDebuger
import XCTest
import SQLite3

class DatabaseManagerTests: XCTestCase {
    
    var mockDatabase: OpaquePointer?

    override func setUp() {
        super.setUp()
        // Create an in-memory database for testing
        if sqlite3_open(":memory:", &mockDatabase) != SQLITE_OK {
            XCTFail("Failed to create in-memory database")
        }
    }

    override func tearDown() {
        if let mockDatabase = mockDatabase {
            sqlite3_close(mockDatabase)
        }
        super.tearDown()
    }

    func testExecuteSQLSuccess() {
        // Given
        let dbManager = SQLDatabaseManager(database: mockDatabase)
        let createTableSQL = "CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)"
        let insertSQL = "INSERT INTO Test (name) VALUES ('John Doe')"
        let querySQL = "SELECT * FROM Test"
        
        // When
        _ = dbManager.executeSQL(createTableSQL)
        _ = dbManager.executeSQL(insertSQL)
        let result = dbManager.executeSQL(querySQL)
        
        // Then
        switch result {
        case .success(let data):
            XCTAssertEqual(data["name"] as? String, "John Doe")
        case .failure(let error):
            XCTFail("Execution failed with error: \(error)")
        }
    }
    
    func testExecuteSQLFailure() {
        // Given
        let dbManager = SQLDatabaseManager(database: mockDatabase)
        let invalidSQL = "SELECT * FROM NonExistentTable"
        
        // When
        let result = dbManager.executeSQL(invalidSQL)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error, .executionFailed(message: "no such table: NonExistentTable"))
        }
    }
}
