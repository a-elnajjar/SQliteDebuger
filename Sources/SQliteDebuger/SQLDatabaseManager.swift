//
//  SQLDatabaseManager.swift
//
//
//  Created by Abdalla Elnajjar on 2024-05-26.
//

import Foundation
import SQLite3

public enum DatabaseError: Error, Equatable {
    case openDatabase(message: String)
    case executionFailed(message: String)
    case databaseNotOpened

    public static func ==(lhs: DatabaseError, rhs: DatabaseError) -> Bool {
        switch (lhs, rhs) {
        case (.openDatabase(let lhsMessage), .openDatabase(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.executionFailed(let lhsMessage), .executionFailed(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.databaseNotOpened, .databaseNotOpened):
            return true
        default:
            return false
        }
    }
}

extension DatabaseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .openDatabase(let message):
            return message
        case .executionFailed(let message):
            return message
        case .databaseNotOpened:
            return "The database is not open."
        }
    }
}

public enum SQLValue: Equatable, CustomStringConvertible {
    case integer(Int64)
    case double(Double)
    case text(String)
    case blob(Data)
    case null

    public var description: String {
        switch self {
        case .integer(let value):
            return String(value)
        case .double(let value):
            return String(value)
        case .text(let value):
            return value
        case .blob(let data):
            return "<\(data.count) bytes>"
        case .null:
            return "NULL"
        }
    }
}

public struct SQLQueryResult: Equatable {
    public let columnNames: [String]
    public let rows: [[SQLValue]]

    public init(columnNames: [String], rows: [[SQLValue]]) {
        self.columnNames = columnNames
        self.rows = rows
    }
}

public protocol DatabaseManagerProtocol {
    @discardableResult
    func openDatabase(named databaseName: String) -> Result<Void, DatabaseError>
    func executeSQL(_ sql: String) -> Result<SQLQueryResult, DatabaseError>
}

public final class SQLDatabaseManager: DatabaseManagerProtocol {
    private var db: OpaquePointer?
    private let baseURL: URL
    private var currentDatabaseURL: URL?

    public init(database: OpaquePointer? = nil, fileManager: FileManager = .default) {
        self.db = database
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.baseURL = documentsURL
        } else {
            self.baseURL = fileManager.temporaryDirectory
        }
        self.currentDatabaseURL = nil
    }

    deinit {
        closeDatabase()
    }

    @discardableResult
    public func openDatabase(named databaseName: String) -> Result<Void, DatabaseError> {
        let databaseURL = baseURL.appendingPathComponent("\(databaseName).sqlite")
        if let currentURL = currentDatabaseURL, currentURL == databaseURL, db != nil {
            return .success(())
        }

        closeDatabase()

        let openResult = sqlite3_open(databaseURL.path, &db)

        guard openResult == SQLITE_OK else {
            let message = db.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "Unable to open database."
            closeDatabase()
            return .failure(.openDatabase(message: message))
        }

        currentDatabaseURL = databaseURL
        return .success(())
    }

    public func executeSQL(_ sql: String) -> Result<SQLQueryResult, DatabaseError> {
        guard let db = db else {
            return .failure(.databaseNotOpened)
        }

        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }

        let prepareResult = sqlite3_prepare_v2(db, sql, -1, &statement, nil)

        guard prepareResult == SQLITE_OK else {
            let message = String(cString: sqlite3_errmsg(db))
            return .failure(.executionFailed(message: message))
        }

        let columnCount = Int(sqlite3_column_count(statement))
        let columnNames = (0..<columnCount).map { index -> String in
            if let name = sqlite3_column_name(statement, Int32(index)) {
                return String(cString: name)
            }
            return "column_\(index)"
        }

        var rows: [[SQLValue]] = []

        while true {
            let stepResult = sqlite3_step(statement)
            switch stepResult {
            case SQLITE_ROW:
                rows.append(readRow(from: statement, columnCount: columnCount))
            case SQLITE_DONE:
                return .success(SQLQueryResult(columnNames: columnNames, rows: rows))
            default:
                let message = String(cString: sqlite3_errmsg(db))
                return .failure(.executionFailed(message: message))
            }
        }
    }

    private func readRow(from statement: OpaquePointer?, columnCount: Int) -> [SQLValue] {
        var row: [SQLValue] = []
        for index in 0..<columnCount {
            let columnType = sqlite3_column_type(statement, Int32(index))
            switch columnType {
            case SQLITE_INTEGER:
                row.append(.integer(sqlite3_column_int64(statement, Int32(index))))
            case SQLITE_FLOAT:
                row.append(.double(sqlite3_column_double(statement, Int32(index))))
            case SQLITE_TEXT:
                if let text = sqlite3_column_text(statement, Int32(index)) {
                    row.append(.text(String(cString: text)))
                } else {
                    row.append(.null)
                }
            case SQLITE_BLOB:
                if let blob = sqlite3_column_blob(statement, Int32(index)) {
                    let length = Int(sqlite3_column_bytes(statement, Int32(index)))
                    row.append(.blob(Data(bytes: blob, count: length)))
                } else {
                    row.append(.null)
                }
            case SQLITE_NULL:
                fallthrough
            default:
                row.append(.null)
            }
        }
        return row
    }

    private func closeDatabase() {
        if let db = db {
            sqlite3_close(db)
            self.db = nil
        }
        currentDatabaseURL = nil
    }
}
