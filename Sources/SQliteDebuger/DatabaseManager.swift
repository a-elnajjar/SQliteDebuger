//
//  DatabaseManager.swift
//
//
//  Created by Abdalla Elnajjar on 2024-05-26.
//

import Foundation
import SQLite3

enum DatabaseError: Error {
    case openDatabase(message: String)
    case executionFailed(message: String)
    case unknown
}

class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: OpaquePointer?
    private var documentsDirectory: String
    private var dbPath: String?

    private init() {
        documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }

    func openDatabase(named databaseName: String) {
        dbPath = (documentsDirectory as NSString).appendingPathComponent("\(databaseName).sqlite")
        
        if let dbPath = dbPath, sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Error opening database: \(String(cString: sqlite3_errmsg(db)))")
        } else {
            print("Successfully opened connection to database at \(dbPath ?? "")")
        }
    }

    func executeSQL(_ sql: String) -> Result<[String: Any], DatabaseError> {
        var queryStatement: OpaquePointer?
        var result: [String: Any] = [:]
        
        if sqlite3_prepare_v2(db, sql, -1, &queryStatement, nil) == SQLITE_OK {
            var columnNames: [String] = []
            let columnCount = sqlite3_column_count(queryStatement)
            
            for index in 0..<columnCount {
                if let columnName = sqlite3_column_name(queryStatement, index) {
                    columnNames.append(String(cString: columnName))
                }
            }
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                for index in 0..<columnCount {
                    if let columnName = columnNames[safe: Int(index)] {
                        let columnType = sqlite3_column_type(queryStatement, index)
                        switch columnType {
                        case SQLITE_INTEGER:
                            result[columnName] = sqlite3_column_int(queryStatement, index)
                        case SQLITE_FLOAT:
                            result[columnName] = sqlite3_column_double(queryStatement, index)
                        case SQLITE_TEXT:
                            if let text = sqlite3_column_text(queryStatement, index) {
                                result[columnName] = String(cString: text)
                            }
                        case SQLITE_BLOB:
                            if let blob = sqlite3_column_blob(queryStatement, index) {
                                let data = Data(bytes: blob, count: Int(sqlite3_column_bytes(queryStatement, index)))
                                result[columnName] = data
                            }
                        case SQLITE_NULL:
                            result[columnName] = nil
                        default:
                            print("Unsupported column type")
                        }
                    }
                }
            }
            
            sqlite3_finalize(queryStatement)
            return .success(result)
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(queryStatement)
            return .failure(.executionFailed(message: errorMessage))
        }
    }
}

// Safe array index access extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
