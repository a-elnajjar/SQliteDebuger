//
//  SQLiteDebugView.swift
//
//
//  Created by Abdalla Elnajjar on 2024-05-26.
//

import SwiftUI

@available(iOS 14.0, *)
public struct SQLiteDebugView: View {
    @State private var databaseName: String = ""
    @State private var sqlStatement: String = ""
    @State private var columnNames: [String] = []
    @State private var results: [[String]] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    private let databaseManager: DatabaseManagerProtocol
    
    // Dependency injection through initializer
    public init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }

    @available(iOS 14.0, *)
    public var body: some View {
        VStack {
            Label("Database Name", systemImage: "database")
            TextField("Enter database name", text: $databaseName)
                .padding()
                .border(Color.gray)
                .frame(width: 300)
            
            Label("SQL Statement", systemImage: "doc.text")
            TextEditor(text: $sqlStatement)
                .padding()
                .border(Color.gray)
                .frame(width: 300, height: 150)
            
            Button("Execute") {
                executeSQL()
            }
            .padding()
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
            }
            
            ScrollView {
                if !columnNames.isEmpty && !results.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnNames.count), alignment: .leading) {
                        // Display column names
                        ForEach(columnNames, id: \.self) { columnName in
                            Text(columnName)
                                .fontWeight(.bold)
                                .padding(5)
                                .background(Color.gray.opacity(0.3))
                        }
                        
                        // Display results
                        ForEach(results, id: \.self) { row in
                            ForEach(row, id: \.self) { item in
                                Text(item)
                                    .padding(5)
                                    .background(Color.gray.opacity(0.1))
                            }
                        }
                    }
                    .padding()
                } else if !isLoading {
                    Text("No results. Please enter a database name and SQL statement, then click Execute.")
                        .padding()
                }
            }
            
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }

    private func executeSQL() {
        isLoading = true
        errorMessage = nil
        
        guard !databaseName.isEmpty else {
            errorMessage = "Please enter a database name"
            isLoading = false
            return
        }
        
        guard !sqlStatement.isEmpty else {
            errorMessage = "Please enter an SQL statement"
            isLoading = false
            return
        }
        
        databaseManager.openDatabase(named: databaseName)
        
        switch databaseManager.executeSQL(sqlStatement) {
        case .success(let result):
            // Extract column names and row data
            columnNames = Array(result.keys)
            results = [Array(result.values.map { String(describing: $0) })]
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}



//@available(iOS 14.0, *)
//#Preview {
//    //SQLiteDebugView()
//}
